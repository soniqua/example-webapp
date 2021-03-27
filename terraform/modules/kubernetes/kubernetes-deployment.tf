
resource "kubernetes_pod" "pod" {
  metadata {
      name = var.name
    }
    spec {
      yamldecode(file(var.pod_file)).spec
    }
}

variable "pod_file" {
  description = "Pod File spec"
}

resource "kubernetes_service" "service" {
  metadata = yamldecode(file(var.service_file)).metadata
  spec = yamldecode(file(var.service_file)).spec
  depends_on = [
    kubernetes_pod.pod
  ]
}

variable "service_file" {
  description = "Pod File spec"
}
