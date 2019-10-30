output "lb_internal_address" {
  value = "${google_compute_forwarding_rule.be.ip_address}"
}