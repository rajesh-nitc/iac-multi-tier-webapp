resource "kubernetes_deployment" "example" {
  metadata {
    name = "nodejs-deployment"
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
          image = "gcr.io/${var.project_id}/${var.myimage_nodejs}"
          name  = "nodejs-container"
          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }

          # {
          #   name = "GF_SECURITY_ADMIN_PASSWORD"

          #   value_from {
          #     secret_key_ref {
          #       key  = "grafana-root-password"
          #       name = "${kubernetes_secret.grafana-secret.metadata.0.name}"
          #     }
          #   }
          # },
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

resource "kubernetes_service" "example1" {
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
