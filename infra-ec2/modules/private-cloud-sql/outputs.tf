# output "reserved_peering_ranges" {
#   value = "${google_compute_global_address.private_ip_address.name}"
# }

output "database_name" {
  value = "${aws_db_instance.default.name}"
}

output "database_private_ip" {
   value = "${aws_db_instance.default.address}"
}

output "database_user" {
  value = "${aws_db_instance.default.username}"
}

output "database_password" {
  value = "${aws_db_instance.default.password}"
}