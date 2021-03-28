# Create a new ECR registry and build a new image from an associated Dockerfile

module "build-example-webapp" {
  source       = "./modules/ecr-image"
  build_folder = "../webapp"
  app_name     = "example-webapp"
  tag          = "0.0.1"
  region       = local.region
  profile      = "cr-lab-mr"
}

# Create a new Kubernetes Namespace

resource "kubernetes_namespace" "example-webapp" {
  metadata {
    labels = {
      name = "example-webapp"
    }
    name = "example-webapp-namespace"
  }
}

# Create a new Kubernetes Pod

resource "kubernetes_pod" "example-webapp" {
  metadata {
    labels = {
      app = "example-webapp"
    }
    name      = "example-webapp"
    namespace = kubernetes_namespace.example-webapp.metadata[0].name
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
      resources {
        limits = {
          cpu    = "1000m"
          memory = "1024Mi"
        }
      }
      security_context {
        allow_privilege_escalation = false
        read_only_root_filesystem  = true
      }
    }
    container {
      name  = "redis"
      image = "redis:6.2.1"
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
      resources {
        limits = {
          cpu    = "1000m"
          memory = "1024Mi"
        }
      }
      security_context {
        allow_privilege_escalation = false
      }
    }
  }
}

# Create a service to expose the web-app

resource "kubernetes_service" "example-webapp" {
  metadata {
    name      = "example-webapp-svc"
    namespace = kubernetes_namespace.example-webapp.metadata[0].name
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
  description = "The URL of the provisioned Load Balancer"
}

output "load_balancer_name" {
  value = local.lb_name
  description = "The name of the Load Balancer"
}
