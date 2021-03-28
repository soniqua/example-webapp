module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.19"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "Example"
  }

  #set access
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = concat(var.api_access_CIDR_range, [for ip in module.vpc.nat_public_ips : "${ip}/32"])
  write_kubeconfig                     = false #do not write out kubeconfig

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2" #GP3 not supported by module.
  }

  worker_groups = [
    #Specify the type of worker groups needed for this cluster.
    {
      name                          = "eks-worker-group"
      instance_type                 = var.instance_type
      asg_desired_capacity          = var.instance_count
      additional_security_group_ids = [aws_security_group.eks_worker.id]
    }
  ]
}

variable "api_access_CIDR_range" {
  type        = list(string)
  description = "CIDR range(s) to be whitelisted for the K8S API endpoint"
}

variable "instance_type" {
  default     = "t3.small"
  type        = string
  description = "A valid AWS EC2 instance type to launch as EKS workers"
}

variable "instance_count" {
  type        = number
  default     = 2
  description = "The number of AWS EC2 instances to launch as EKS workers"
}

resource "aws_iam_role_policy_attachment" "eks_worker_cloudwatch" {
  role       = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
