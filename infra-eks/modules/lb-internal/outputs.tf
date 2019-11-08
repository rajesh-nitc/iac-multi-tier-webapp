 output "nodejs_service" {
   value = "${kubernetes_service.example.metadata[0].name}"
 }