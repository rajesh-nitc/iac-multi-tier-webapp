output "nodejs_service" {
  value = "${kubernetes_service.example1.metadata[0].name}"
}