output "lb_global_address" {
  value = kubernetes_service.nginx.load_balancer_ingress[0].ip
}

# output "subnet_name" {
#     value = "${google_compute_subnetwork.default.name}"
# }

# output "network_name" {
#     value = "${google_compute_network.default.name}"
# }

# output "network_self_link" {
#     value = "${google_compute_network.default.self_link}"
# }

