# Namespace
# IAM role
#

resource "kubernetes_namespace" "cloudwatch" {
  metadata {
    annotations = {
      name = "amazon-cloudwatch"
    }
    name = "amazon-cloudwatch"
  }
}

# Service Account

resource "kubernetes_service_account" "cloudwatch" {
  metadata {
    name      = "cloudwatch-agent"
    namespace = kubernetes_namespace.cloudwatch.metadata[0].name
  }
}

# Cluster Role

resource "kubernetes_role" "cloudwatch" {
  metadata {
    name = "cloudwatch-agent-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "nodes", "endpoints"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["replicasets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/proxy"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/stats", "configmaps", "events"]
    verbs      = ["create"]
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["cwagent-clusterleader"]
    verbs          = ["get", "update"]
  }
}

# Bind the role

resource "kubernetes_role_binding" "cloudwatch" {
  metadata {
    name = "cloudwatch-agent-role-binding"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cloudwatch.metadata[0].name
    namespace = kubernetes_namespace.cloudwatch.metadata[0].name
  }
  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_role.cloudwatch.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_config_map" "cloudwatch" {
  metadata {
    name      = "cwagentconfig"
    namespace = kubernetes_namespace.cloudwatch.metadata[0].name
  }
  data = {
    "cwagentconfig.json" = file("${path.module}/cwagentconfig.json") #todo - template this
  }
}

resource "kubernetes_daemonset" "cloudwatch" {
  metadata {
    name      = "cloudwatch-agent"
    namespace = "amazon-cloudwatch"
  }
  spec {
    selector {
      match_labels = {
        name = "cloudwatch-agent"
      }
    }
    template {
      metadata {
        labels = {
          name = "cloudwatch-agent"
        }
      }
      spec {
        service_account_name             = "cloudwatch-agent"
        termination_grace_period_seconds = 60
        volume {
          config_map {
            name = "cwagentconfig"
          }
          name = "cwagentconfig"
        }
        volume {
          host_path {
            path = "/"
          }
          name = "rootfs"
        }
        volume {
          host_path {
            path = "/var/run/docker.sock"
          }
          name = "dockersock"
        }
        volume {
          host_path {
            path = "/var/lib/docker"
          }
          name = "varlibdocker"
        }
        volume {
          host_path {
            path = "/sys"
          }
          name = "sys"
        }
        volume {
          host_path {
            path = "/dev/disk/"
          }
          name = "devdisk"
        }
        container {
          env {
            name = "HOST_IP"
            value_from {
              field_ref {
                field_path = "status.hostIP"
              }
            }
          }
          env {
            name = "HOST_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          env {
            name = "K8S_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name  = "CI_VERSION"
            value = "k8s/1.3.5"
          }
          image = "amazon/cloudwatch-agent:1.247347.5b250583"
          name  = "cloudwatch-agent"
          resources {
            limits = {
              cpu    = "200m"
              memory = "200Mi"
            }
            requests = {
              cpu    = "200m"
              memory = "200Mi"
            }
          }
          volume_mount {
            mount_path = "/etc/cwagentconfig"
            name       = "cwagentconfig"
          }
          volume_mount {
            mount_path = "/rootfs"
            name       = "rootfs"
            read_only  = true

          }
          volume_mount {
            mount_path = "/var/run/docker.sock"
            name       = "dockersock"
            read_only  = true
          }
          volume_mount {
            mount_path = "/var/lib/docker"
            name       = "varlibdocker"
            read_only  = true
          }
          volume_mount {
            mount_path = "/sys"
            name       = "sys"
            read_only  = true
          }
          volume_mount {
            mount_path = "/dev/disk"
            name       = "devdisk"
            read_only  = true
          }
        }
      }
    }
  }
}
