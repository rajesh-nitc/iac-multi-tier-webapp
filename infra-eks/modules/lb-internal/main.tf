resource "kubernetes_deployment" "example" {
  metadata {
    name = "nodejs-deployment2"
    labels = {
      App = "${var.app_label_nodejs}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        App = "${var.app_label_nodejs}"
      }
    }

    template {
      metadata {
        labels = {
          App = "${var.app_label_nodejs}"
        }
      }

      spec {
        container {
          image = "${var.CONTAINER_IMAGE_NODE}"
          name  = "nodejs-container"
          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }
          
          env {
            name  = "PORT"
            value = "3000"
          }
          env {
            name  = "MYSQL_HOST"
            value = "${var.database_host}"
          }
          env {
            name  = "MYSQL_DATABASE"
            value = "${var.database_name}"
          }
          env {
            name  = "MYSQL_USER"
            value = "${var.database_user}"
          }
          env {
            name  = "MYSQL_PASSWORD"
            value = "${var.database_password}"
          }

        }

      }
    }
  }
}

 resource "kubernetes_service" "example" {
   metadata {
     name = "nodejsservice"
   }
   spec {
     selector = {
       App = kubernetes_deployment.example.spec.0.template.0.metadata[0].labels.App
     }
     port {
       port        = 80
       target_port = 3000
    }

     type = "ClusterIP"
   }
 }
