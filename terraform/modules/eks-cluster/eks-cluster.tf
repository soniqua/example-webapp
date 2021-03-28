module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.19"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "Example"
  }

  #set access
  cluster_endpoint_public_access =true
  cluster_endpoint_private_access =true
  cluster_endpoint_public_access_cidrs = concat(var.api_access_CIDR_range, [for ip in module.vpc.nat_public_ips : "${ip}/32"])

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2" #GP3 not supported
  }

  worker_groups = [
    #Specify the type of worker groups needed for this cluster.
    {
      name                          = "eks-worker-group"
      instance_type                 = "t3.small"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.eks_worker.id]
    }
  ]

}

variable "api_access_CIDR_range" {
  type = list(string)
  description = "CIDR range(s) to be whitelisted for the K8S API endpoint"
}
