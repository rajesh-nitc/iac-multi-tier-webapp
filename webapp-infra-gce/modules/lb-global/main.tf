# to do:  add ssl
resource "google_compute_network" "default" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "default" {
  name                     = "${var.network_name}-subnet01"
  ip_cidr_range = "10.0.1.0/24"
  network                  = "${google_compute_network.default.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = true
  enable_flow_logs = true
}


resource "google_compute_firewall" "fe" {
  name    = "webapp"
  network = "${google_compute_network.default.name}"
  project = "${var.project_id}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3000"]
  }

  # target_tags   = ["fe-vm"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance_template" "fe" {
  name_prefix  = "fe-template-"
  machine_type = "f1-micro"
  region       = "asia-south1"
  can_ip_forward       = true
  # tags         = ["fe-vm"]

  metadata_startup_script = templatefile("${path.module}/templates/startup-script.tmpl", {
    project_id = "${var.project_id}",
    repo_name  = "${var.repo_client}",
  })

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.default.name}"

    access_config {
    }
  }
  service_account {
    scopes = ["cloud-platform"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_instance_group_manager" "fe" {
  name = "fe-mig"
  base_instance_name = "fe"
  instance_template  = "${google_compute_instance_template.fe.self_link}"
  update_strategy    = "ROLLING_UPDATE"
  zone               = "asia-south1-a"

  named_port {
    name = "http"
    port = 80
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_global_address" "fe" {
  name = "fe-address"
}

resource "google_compute_health_check" "fe" {
  name               = "fe-healthcheck"
  check_interval_sec = 5
  timeout_sec        = 1

  http_health_check {
    port         = "80"
    request_path = "/"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_backend_service" "fe" {
  name          = "fe-backend-service"
  port_name     = "http"
  protocol      = "HTTP"
  health_checks = ["${google_compute_health_check.fe.self_link}"]

  backend {
    group = "${google_compute_instance_group_manager.fe.instance_group}"
  }
}

resource "google_compute_url_map" "fe" {
  name = "fe-url-map"
  default_service = "${google_compute_backend_service.fe.self_link}"
}

resource "google_compute_target_http_proxy" "fe" {
  name    = "fe-http-proxy"
  url_map = "${google_compute_url_map.fe.self_link}"
}
resource "google_compute_global_forwarding_rule" "fe" {
  name       = "fe-forwarding-rule-http"
  port_range = "80"
  ip_address = "${google_compute_global_address.fe.address}"
  target     = "${google_compute_target_http_proxy.fe.self_link}"
}

resource "google_compute_autoscaler" "fe" {
  name   = "fe-autoscaler"
  zone   = "asia-south1-a"
  target = "${google_compute_instance_group_manager.fe.self_link}"

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}