//===================================================================
// vars 
//===================================================================
variable "subscription_id" {
  default = "xyz"
}

variable "client_id" {
  default = "xyz"
}

variable "client_secret" {
  default = "xyz"
}

variable "tenant_id" {
  default = "xyz"
}

variable "admin_password" {
  default = "xyz"
}

variable "context" {
  default = "xyz"
}

//===================================================================
// Provider setup 
//===================================================================
provider "azurerm" {
  version = ">= 2.41.0"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.context
}


//===================================================================
// Get ingress service
//===================================================================
/* data "kubernetes_service" "internal-ingress" {
  metadata {
    name = "nginx-ingress-controller"
    namespace = "ingress"
  }
} */

data "azurerm_lb" "lb" {
  name                = "kubernetes"
  resource_group_name = "MC_eu-az-nft-wal-aks-rg_eu-az-nft-wal_westeurope"
}


output "lb" {
  value               = data.azurerm_lb.lb
}

/* output "internal-ingress" {
  value = data.kubernetes_service.internal-ingress
}
 */





