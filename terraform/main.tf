## Create a new EKS Cluster, along with supporting infrastructure

locals {
  region               = "eu-west-2"
  use_sts              = true
  use_credentials_file = true
  role_arn             = "arn:aws:iam::772290144575:role/Admin"
  profile              = "cr-lab"
  allowed_access_cidrs = ["88.98.247.243/32"]
  allowed_account_ids  = ["772290144575"]
}

module "eks-cluster" {
  source                = "./modules/eks-cluster"
  region                = local.region
  api_access_CIDR_range = local.allowed_access_cidrs #The address of the NAT gateway will be added automatically.
  instance_type         = "t3.small"
  instance_count        = 2
}
