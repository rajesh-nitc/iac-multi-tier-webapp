output "reserved_peering_ranges" {
  value = "${google_compute_global_address.private_ip_address.name}"
}

output "database_name" {
  value = "${google_sql_database.database.name}"
}

output "database_private_ip" {
  value = "${google_sql_database_instance.instance.private_ip_address}"
}

output "database_user" {
  value = "${google_sql_user.users.name}"
}

output "database_password" {
  value = "${google_sql_user.users.password}"
}