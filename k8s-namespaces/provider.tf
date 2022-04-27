provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "spantest-fs-aks-cluster-admin"
}