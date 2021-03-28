# data sources required for providers
data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name,
      "--role-arn",   # Need to add this if using STS to access cluster
      local.role_arn, # May be ommitted if STS is not used.
      "--profile",
      local.profile
    ]
  }
}

## Use local state (not production ready, but requires no additional pre-reqs.
provider "aws" {
  region                  = local.region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = local.profile
  assume_role {
    role_arn = local.role_arn
  }
  allowed_account_ids = ["772290144575"]
}
