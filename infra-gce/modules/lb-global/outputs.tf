output "lb_global_address" {
  value = "${google_compute_global_forwarding_rule.fe.ip_address}"
}

output "subnet_name" {
    value = "${google_compute_subnetwork.default.name}"
}

output "network_name" {
    value = "${google_compute_network.default.name}"
}

output "network_self_link" {
    value = "${google_compute_network.default.self_link}"
}

