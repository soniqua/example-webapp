## Create a new EKS Cluster, along with supporting infrastructure

locals {
  region = "us-west-2"
  role_arn = "arn:aws:iam::772290144575:role/Admin"
  profile = "cr-lab"
}

module "eks-cluster" {
  source = "./modules/eks-cluster"
  region = local.region
}

module "build-example-webapp" {
  source = "./modules/ecr-image"
  build_folder = "../webapp"
  app_name = "example-webapp"
  tag = "0.0.1"
  region = local.region
  profile = "cr-lab-mr"
}

# resource "kubernetes_service" "example-webapp" {
#   metadata {
#     name = "example-webapp"
#   }
#   spec {
#     type = "LoadBalancer"
#     port {
#       port = 80
#       target_port = 3000
#     }
#     selector {
#       app = "example_webapp"
#     }
#   }
# }

# resource "kubernetes_pod" "example-webapp" {
#   metadata {
#     name = "example-webapp"
#     labels {
#       app = "example-webapp"
#     }
#     spec {
#       container {
#
#       }
#     }
#   }
# }

# module "launch-example-webapp" {
#   source = "./modules/kubernetes"
#   pod_file = "./k8s/example-webapp/example-webapp.pod.yaml"
#   service_file = "./k8s/example-webapp/example-webapp.service.yaml"
# }
