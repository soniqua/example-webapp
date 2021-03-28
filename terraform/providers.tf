# data sources required for providers
data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

# Set this command to either use sts (add a role_arn) or ignore:
locals {
  k8s_exec_cmd = local.use_sts ? [
    "eks",
    "get-token",
    "--cluster-name",
    data.aws_eks_cluster.cluster.name,
    "--role-arn",
    local.role_arn,
    "--profile",
    local.profile,
    "--region",
    local.region
    ] : [
    "eks",
    "get-token",
    "--cluster-name",
    data.aws_eks_cluster.cluster.name,
    "--profile",
    local.profile,
    "--region",
    local.region
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args        = local.k8s_exec_cmd
  }
}

## Use local state (not production ready, but requires no additional pre-reqs.
provider "aws" {
  region                  = local.region
  shared_credentials_file = local.use_credentials_file ? "~/.aws/credentials" : null
  profile                 = local.profile
  assume_role {
    role_arn = local.use_sts ? local.role_arn : null
  }
  allowed_account_ids = local.allowed_account_ids # Update to the target AWS account
}
