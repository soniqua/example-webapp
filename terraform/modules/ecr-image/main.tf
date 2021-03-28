# Build a docker image - use shell script

data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "repo" {
  name                 = var.app_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true # CKV_AWS_33
  }
}

resource "null_resource" "push_image" {
  triggers = {
    tag = var.tag
  }
  depends_on = [
    aws_ecr_repository.repo
  ]
  provisioner "local-exec" {
    command = "${path.module}/build.sh ${var.build_folder} ${var.tag} ${aws_ecr_repository.repo.repository_url} ${var.profile} ${var.region} ${data.aws_caller_identity.current.account_id}"
  }
}

variable "app_name" {
  description = "The name of the container to build"
}

variable "tag" {
  description = "The version of the container to be built"
}

variable "build_folder" {
  description = "The folder containing a Dockerfile for building"
}

variable "profile" {
  description = "The AWS profile to use for ECR Login commands"
}

variable "region" {
  description = "The region of the ECR repository to push to"
}

output "image_name" {
  description = "The image name (including tag)"
  value       = "${aws_ecr_repository.repo.repository_url}:${var.tag}"
}
