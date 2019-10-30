resource "google_compute_instance_template" "be" {
  name_prefix    = "be-template"
  machine_type   = "f1-micro"
  can_ip_forward = true
  region         = "asia-south1"
  #   tags         = ["instance-template"]
  metadata_startup_script = templatefile("${path.module}/templates/startup-script.tmpl", {
    project_id        = "${var.project_id}",
    repo_name         = "${var.repo_server}",
    database_host     = "${var.database_host}",
    database_name     = "${var.database_name}",
    database_user     = "${var.database_user}",
    database_password = "${var.database_password}"
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
    subnetwork = "${var.subnet_name}"

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

resource "google_compute_instance_group_manager" "be" {
  name = "be-mig"

  base_instance_name = "be"
  instance_template  = "${google_compute_instance_template.be.self_link}"
  update_strategy    = "ROLLING_UPDATE"
  zone               = "asia-south1-a"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_backend_service" "be" {
  name                            = "region-backend-service"
  region                          = "${var.region}"
  health_checks                   = ["${google_compute_health_check.be.self_link}"]
  connection_draining_timeout_sec = 10
  session_affinity                = "CLIENT_IP"

  backend {
    group = "${google_compute_instance_group_manager.be.instance_group}"
  }
}

resource "google_compute_health_check" "be" {
  name               = "health-check"
  check_interval_sec = 1
  timeout_sec        = 1

  tcp_health_check {
    port = "80"
  }
}

resource "google_compute_forwarding_rule" "be" {
  name   = "be-forwarding-rule"
  region = "${var.region}"

  load_balancing_scheme = "INTERNAL"
  backend_service       = "${google_compute_region_backend_service.be.self_link}"
  all_ports             = true
  network               = "${var.network_name}"
  subnetwork            = "${var.subnet_name}"
}

# resource "google_compute_route" "route-ilb-beta" {
#   provider     = "google-beta"
#   name         = "route-ilb-beta"
#   dest_range   = "0.0.0.0/0"
#   network      = "${var.network_name}"
#   next_hop_ilb = "${google_compute_forwarding_rule.be.self_link}"
#   priority     = 2000
# }

resource "google_compute_autoscaler" "be" {
  name   = "be-autoscaler"
  zone   = "asia-south1-a"
  target = "${google_compute_instance_group_manager.be.self_link}"

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}
