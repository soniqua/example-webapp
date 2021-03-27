resource "aws_ecr_repository" "k8s" {
  name                 = "k8s"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
