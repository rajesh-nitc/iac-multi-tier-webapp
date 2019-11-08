output "lb_global_address" {
  value = "${module.lb_global.lb_global_address}"
}

output "lb_internal_address" {
  value = "${module.lb_internal.lb_internal_address}"
}

output "subnet_name" {
    value = "${module.lb_global.subnet_name}"
}

output "network_name" {
    value = "${module.lb_global.network_name}"
}

output "reserved_peering_ranges" {
  value = "${module.private_cloud_sql.reserved_peering_ranges}"
}

output "database_name" {
  value = "${module.private_cloud_sql.database_name}"
}

output "network_self_link" {
    value = "${module.lb_global.network_self_link}"
}

output "database_private_ip" {
  value = "${module.private_cloud_sql.database_private_ip}"
}

output "database_user" {
  value = "${module.private_cloud_sql.database_user}"
}

output "database_password" {
  value = "${module.private_cloud_sql.database_password}"
}