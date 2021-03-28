resource "kubernetes_service_account" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = "amazon-cloudwatch"
  }
}

resource "kubernetes_cluster_role" "fluent_bit_role" {
  metadata {
    name = "fluent-bit-role"
  }

  rule {
    verbs             = ["get"]
    non_resource_urls = ["/metrics"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces", "pods", "pods/logs"]
  }
}

resource "kubernetes_config_map" "fluent_bit_config_map" {
  metadata {
    name      = "fluent-bit-cluster-info"
    namespace = "amazon-cloudwatch"
  }
  data = {
    "cluster.name" = local.cluster_name
    "http.server"  = "On"
    "http.port"    = 2020
    "read.head"    = "Off"
    "read.tail"    = "On"
    "logs.region"  = var.region
  }
}

resource "kubernetes_cluster_role_binding" "fluent_bit_role_binding" {
  metadata {
    name = "fluent-bit-role-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "fluent-bit"
    namespace = "amazon-cloudwatch"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "fluent-bit-role"
  }
}

resource "kubernetes_config_map" "fluent_bit_config" {
  metadata {
    name      = "fluent-bit-config"
    namespace = "amazon-cloudwatch"

    labels = {
      k8s-app = "fluent-bit"
    }
  }

  data = {
    "fluent-bit.conf"      = file("${path.module}/fluent-bit-conf/fluent-bit.conf")
    "application-log.conf" = file("${path.module}/fluent-bit-conf/application-log.conf")
    "dataplane-log.conf"   = file("${path.module}/fluent-bit-conf/dataplane-log.conf")
    "host-log.conf"        = file("${path.module}/fluent-bit-conf/host-log.conf")
    "parsers.conf"         = file("${path.module}/fluent-bit-conf/parsers.conf")
  }
}

resource "kubernetes_daemonset" "fluent_bit" {
  metadata {
    name      = "fluent-bit"
    namespace = "amazon-cloudwatch"

    labels = {
      k8s-app                         = "fluent-bit"
      "kubernetes.io/cluster-service" = "true"
      version                         = "v1"
    }
  }

  spec {
    selector {
      match_labels = {
        k8s-app = "fluent-bit"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app                         = "fluent-bit"
          "kubernetes.io/cluster-service" = "true"
          version                         = "v1"
        }
      }

      spec {
        volume {
          name = "fluentbitstate"
          host_path {
            path = "/var/fluent-bit/state"
          }
        }

        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }

        volume {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }

        volume {
          name = "fluent-bit-config"
          config_map {
            name = "fluent-bit-config"
          }
        }

        volume {
          name = "runlogjournal"
          host_path {
            path = "/run/log/journal"
          }
        }

        volume {
          name = "dmesg"
          host_path {
            path = "/var/log/dmesg"
          }
        }

        container {
          name  = "fluent-bit"
          image = "amazon/aws-for-fluent-bit:2.10.0"
          env {
            name = "AWS_REGION"

            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "logs.region"
              }
            }
          }

          env {
            name = "CLUSTER_NAME"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "cluster.name"
              }
            }
          }

          env {
            name = "HTTP_SERVER"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "http.server"
              }
            }
          }

          env {
            name = "HTTP_PORT"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "http.port"
              }
            }
          }

          env {
            name = "READ_FROM_HEAD"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "read.head"
              }
            }
          }

          env {
            name = "READ_FROM_TAIL"
            value_from {
              config_map_key_ref {
                name = "fluent-bit-cluster-info"
                key  = "read.tail"
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
            name  = "CI_VERSION"
            value = "k8s/1.3.5"
          }

          resources {
            limits = {
              memory = "200Mi"
            }

            requests = {
              cpu    = "500m"
              memory = "100Mi"
            }
          }

          volume_mount {
            name       = "fluentbitstate"
            mount_path = "/var/fluent-bit/state"
          }

          volume_mount {
            name       = "varlog"
            read_only  = true
            mount_path = "/var/log"
          }

          volume_mount {
            name       = "varlibdockercontainers"
            read_only  = true
            mount_path = "/var/lib/docker/containers"
          }

          volume_mount {
            name       = "fluent-bit-config"
            mount_path = "/fluent-bit/etc/"
          }

          volume_mount {
            name       = "runlogjournal"
            read_only  = true
            mount_path = "/run/log/journal"
          }

          volume_mount {
            name       = "dmesg"
            read_only  = true
            mount_path = "/var/log/dmesg"
          }

          image_pull_policy = "Always"
        }

        termination_grace_period_seconds = 10
        service_account_name             = "fluent-bit"

        toleration {
          key      = "node-role.kubernetes.io/master"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        toleration {
          operator = "Exists"
          effect   = "NoExecute"
        }

        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }
  }
}
