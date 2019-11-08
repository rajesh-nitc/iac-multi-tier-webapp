resource "google_compute_global_address" "private_ip_address" {
  provider = "google-beta"

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 16
  network       = "${var.network_name}"
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = "google-beta"

  network       = "${var.network_name}"
  service       = "servicenetworking.googleapis.com"
  reserved_peering_ranges = ["${google_compute_global_address.private_ip_address.name}"]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  provider = "google-beta"

  name = "private-instance-${random_id.db_name_suffix.hex}"
  region = "${var.region}"

  depends_on = [
    "google_service_networking_connection.private_vpc_connection"
  ]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = false
      private_network = "${var.network_name}"
    }
  }
}

resource "google_sql_database" "database" {
    name = "my-database"
    instance = "${google_sql_database_instance.instance.name}"
}

resource "google_sql_user" "users" {
  name     = "rajesh"
  instance = "${google_sql_database_instance.instance.name}"
  # host     = "me.com"
  password = "master12"
}