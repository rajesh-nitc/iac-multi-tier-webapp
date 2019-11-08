provider "google" {
  version = "~> 2.1"
  region  = "${var.region}"
  project = "${var.project_id}"
  zone    = "${var.region}-a"
}

provider "google-beta" {
  version = "~> 2.1"
  region  = "${var.region}"
  project = "${var.project_id}"
  zone    = "${var.region}-a"
}

resource "google_compute_network" "default" {
  name                    = "${var.network_name}"
  auto_create_subnetworks = "false"
}

resource "google_compute_firewall" "fe" {
  name    = "cluster-firewall"
  network = "${google_compute_network.default.name}"
  project = "${var.project_id}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_container_cluster" "primary" {
  name                     = "my-gke-cluster"
  location                 = "${var.region}-a"
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = google_compute_network.default.name
  ip_allocation_policy {
    create_subnetwork = true
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "${var.region}-a"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only", // allows to pull images from gcr
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }
}

# After creating the cluster:
data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name     = "${google_container_cluster.primary.name}"
  location = "${var.region}-a"
}

provider "kubernetes" {
  config_context_cluster = "${google_container_cluster.primary.name}"
  load_config_file       = false
  host                   = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token                  = "${data.google_client_config.default.access_token}"
  cluster_ca_certificate = "${base64decode(data.google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate)}"
}

module "lb_global" {
  source            = "../../../modules/lb-global"
  project_id        = "${var.project_id}"
  app_label_nginx   = "${var.app_label_nginx}"
  myimage_nginx     = "${var.myimage_nginx}"
  create_dependency = "${module.lb_internal.nodejs_service}"
}

module "lb_internal" {
  source            = "../../../modules/lb-internal"
  project_id        = "${var.project_id}"
  app_label_nodejs  = "${var.app_label_nodejs}"
  myimage_nodejs    = "${var.myimage_nodejs}"
  database_host     = "${module.private_cloud_sql.database_private_ip}"
  database_name     = "${module.private_cloud_sql.database_name}"
  database_user     = "${module.private_cloud_sql.database_user}"
  database_password = "${module.private_cloud_sql.database_password}"
}

module "private_cloud_sql" {
  source       = "../../../modules/private-cloud-sql"
  network_name = google_compute_network.default.self_link
  region       = "${var.region}"
}
