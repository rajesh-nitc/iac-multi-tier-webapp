resource "kubernetes_deployment" "example" {

  metadata {
    name = "nginx-deployment"
    labels = {
      App  = "${var.app_label_nginx}"
      Test = "${var.create_dependency}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        App  = "${var.app_label_nginx}"
        Test = "${var.create_dependency}"

      }
    }

    template {
      metadata {
        labels = {
          App  = "${var.app_label_nginx}"
          Test = "${var.create_dependency}"

        }
      }

      spec {
        container {
          image = "gcr.io/${var.project_id}/${var.myimage_nginx}"
          name  = "nginx-container"
          port {
            name           = "http"
            container_port = 80
            protocol       = "TCP"
          }

          volume_mount {
            mount_path = "/etc/nginx/conf.d"
            name       = "nginx-config-volume"
          }

          # liveness_probe {
          #   http_get {
          #     path = "/"
          #     port = 80

          #     # http_header {
          #     #   name  = "X-Custom-Header"
          #     #   value = "Awesome"
          #     # }
          #   }

          #   initial_delay_seconds = 3
          #   period_seconds        = 3
          # }

          # resources {
          #   limits {
          #     cpu    = "0.5"
          #     memory = "512Mi"
          #   }
          #   requests {
          #     cpu    = "250m"
          #     memory = "50Mi"
          #   }
          # }

        }

        volume {
          name = "nginx-config-volume"
          config_map {
            name = kubernetes_config_map.example.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-service"
  }
  spec {
    selector = {
      App  = kubernetes_deployment.example.spec.0.template.0.metadata[0].labels.App
      Test = kubernetes_deployment.example.spec.0.template.0.metadata[0].labels.Test

    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_config_map" "example" {
  metadata {
    name = "nginx-config-map"
  }

  data = {
    "default.conf" = file("${path.module}/files/default.conf")
  }
}
