## Create a new EKS Cluster, along with supporting infrastructure

locals {
  region = "eu-west-2"
  role_arn = "arn:aws:iam::772290144575:role/Admin"
  profile = "cr-lab"
  current_ip = ["88.98.247.243/32"]
}

module "eks-cluster" {
  source = "./modules/eks-cluster"
  region = local.region
  api_access_CIDR_range = local.current_ip #The address of the NAT gateway will be added automatically.
}
