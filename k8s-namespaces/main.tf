
locals {
  namespace = "bob"
  count = contains(data.kubernetes_all_namespaces.allns.namespaces, local.namespace) == false ? 1 : 0
}

data "kubernetes_all_namespaces" "allns" {}

resource "kubernetes_namespace" "ns" {
  count = local.count

  lifecycle {
    ignore_changes = [count]
  }

  metadata {
    name = local.namespace
    labels = {
      istio-injection = "enabled"
    }
  }
}


