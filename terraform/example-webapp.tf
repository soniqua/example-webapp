# Create a new ECR registry and build a new image from an associated Dockerfile

module "build-example-webapp" {
  source       = "./modules/ecr-image"
  build_folder = "../webapp"
  app_name     = "example-webapp"
  tag          = "0.0.1"
  region       = local.region
  profile      = "cr-lab-mr"
}

# Create a new Kubernetes Pod

resource "kubernetes_pod" "example-webapp" {
  metadata {
    labels = {
      app = "example-webapp"
    }
    name = "example-webapp"
  }
  spec {
    container {
      name  = "webapp"
      image = module.build-example-webapp.image_name
      port {
        container_port = 3000
      }
      liveness_probe {
        http_get {
          path = "/info" #Add liveness_probe to ensure webapp is ready and can connect to redis
          port = 3000

          http_header {
            name  = "X-Kubernetes-Liveness-Probe"
            value = "OK"
          }
        }
        initial_delay_seconds = 5
        period_seconds        = 5
      }
    }
    container {
      name  = "redis"
      image = "redis"
      port {
        container_port = 6379
      }
      liveness_probe {
        exec {
          command = ["redis-cli", "ping"] #Add liveness_probe to ensure redis is ready
        }
        initial_delay_seconds = 5
        period_seconds        = 5
      }
    }
  }
}

# Create a service to expose the web-app

resource "kubernetes_service" "example-webapp" {
  metadata {
    name = "example-webapp-svc"
  }
  spec {
    selector = {
      app = kubernetes_pod.example-webapp.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 3000
    }
    type                        = "LoadBalancer"
    load_balancer_source_ranges = local.current_ip
  }
}

locals {
  lb_name = split("-", split(".", kubernetes_service.example-webapp.status.0.load_balancer.0.ingress.0.hostname).0).0
}

data "aws_elb" "lb" {
  name = local.lb_name
}

output "load_balancer_hostname" {
  value = kubernetes_service.example-webapp.status.0.load_balancer.0.ingress.0.hostname
}

output "load_balancer_name" {
  value = local.lb_name
}

output "load_balancer_info" {
  value = data.aws_elb.lb
}
