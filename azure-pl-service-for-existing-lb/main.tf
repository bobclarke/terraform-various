//===================================================================
// Logic
//===================================================================
/*  
 Get the IP for the correct igress controller
 This will tell you which Front end config to use (i.e many igress controllers use the same LB) 
*/


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

variable "location" {
  default = "xyz"
}

variable "resource_group_name" {
  default = "xyz"
}

//===================================================================
// Provider setup 
//===================================================================
provider "azurerm" {
  version = ">= 2.41.0"
  //version = "1.11.2"
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
  version = "1.11.2"
}


//===================================================================
// Get the ingress controller details
//===================================================================
data "kubernetes_service" "internal-ingress" {
  metadata {
    name = "nginx-ingress-controller"
    namespace = "ingress"
  }
}

data "kubernetes_service" "external-ingress" {
  metadata {
    name = "external-nginx-ingress-controller"
    namespace = "ingress-external"
  }
}

locals {
  //internal_ingress_ip = data.kubernetes_service.internal-ingress.status.0.load_balancer.0.ingress.0.ip
  //external_ingress_ip = data.kubernetes_service.external-ingress.status.0.load_balancer.0.ingress.0.ip
  iigw_svc_ip =           data.kubernetes_service.istio_gateway.spec[0].external_ips
}

//===================================================================
// Build a map of Load Balancer front end IP configs keyed on IP address
//===================================================================
data "azurerm_lb" "lb" {
  name                = "kubernetes-internal"
  resource_group_name = "MC_eu-az-nft-wal-aks-rg_eu-az-nft-wal_westeurope"
}

locals {
  feconfigs = {
    for feconfig in data.azurerm_lb.lb.frontend_ip_configuration:
      "${feconfig.private_ip_address}" => {
        "subnet_id" = feconfig.subnet_id
        "load_balancer_frontend_ip_configuration_id" = feconfig.id
      }
    }
}

//===================================================================
// Now we can retrieve the FE config and Subnet ID's for this IP 
//===================================================================

locals {
  internal_lb_feconfig = local.feconfigs[local.internal_ingress_ip].load_balancer_frontend_ip_configuration_id
  internal_lb_subnet = local.feconfigs[local.internal_ingress_ip].subnet_id
  external_lb_feconfig = local.feconfigs[local.external_ingress_ip].load_balancer_frontend_ip_configuration_id
  external_lb_subnet = local.feconfigs[local.external_ingress_ip].subnet_id

}

output "feconfigs" {
  value               = local.feconfigs
}


output "internal_lb_feconfig" {
  value               = local.internal_lb_feconfig
}
output "internal_lb_subnet" {
  value               = local.internal_lb_subnet
}
output "internal_ingress_ip" {
  value               = local.internal_ingress_ip 
}   

output "external_lb_feconfig" {
  value               = local.external_lb_feconfig
}
output "external_lb_subnet" {
  value               = local.external_lb_subnet
}
output "external_ingress_ip" {
  value               = local.external_ingress_ip 
}   


//===================================================================
// Add the PrivateLink Services
//===================================================================

resource "azurerm_private_link_service" "internal-pl-service" {
  name                = "internal-pl-service"
  location            = "westeurope"
  resource_group_name = "MC_eu-az-nft-wal-aks-rg_eu-az-nft-wal_westeurope"

  auto_approval_subscription_ids              = ["968853fd-f3eb-4840-a1ee-536cfdea8092"]
  visibility_subscription_ids                 = ["968853fd-f3eb-4840-a1ee-536cfdea8092"]

  nat_ip_configuration {
    name      = "nat_ip_config"
    primary   = true
    subnet_id = local.internal_lb_subnet
  }

  load_balancer_frontend_ip_configuration_ids = [
    local.internal_lb_feconfig,
  ]
}

resource "azurerm_private_link_service" "external-pl-service" {
  name                = "external-pl-service"
  location            = "westeurope"
  resource_group_name = "MC_eu-az-nft-wal-aks-rg_eu-az-nft-wal_westeurope"

  auto_approval_subscription_ids              = ["968853fd-f3eb-4840-a1ee-536cfdea8092"]
  visibility_subscription_ids                 = ["968853fd-f3eb-4840-a1ee-536cfdea8092"]

  nat_ip_configuration {
    name      = "nat_ip_config"
    primary   = true
    subnet_id = local.external_lb_subnet
  }

  load_balancer_frontend_ip_configuration_ids = [
    local.external_lb_feconfig,
  ]
}






