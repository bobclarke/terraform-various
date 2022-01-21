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
// Get the ingress controller details
//===================================================================
data "kubernetes_service" "internal-ingress" {
  metadata {
    name = "nginx-ingress-controller"
    namespace = "ingress"
  }
}

locals {
  ingress_ip = data.kubernetes_service.internal-ingress.status.0.load_balancer.0.ingress.0.ip
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
  lb_feconfig = local.feconfigs[local.ingress_ip].load_balancer_frontend_ip_configuration_id
  lb_subnet = local.feconfigs[local.ingress_ip].subnet_id
}

output "subnet" {
  value               = local.lb_subnet
}

output "feconfig" {
  value               = local.lb_feconfig
}

//===================================================================
// Add the PrivateLink Service
//===================================================================
resource "azurerm_private_link_service" "pl-service" {
  name                = "pl-service"
  location            = "westeurope"
  resource_group_name = "MC_eu-az-nft-wal-aks-rg_eu-az-nft-wal_westeurope"

  auto_approval_subscription_ids              = [var.subscription_id]
  visibility_subscription_ids                 = [var.subscription_id]

  nat_ip_configuration {
    name      = "nat_ip_config"
    primary   = true
    subnet_id = local.lb_subnet
  }

  load_balancer_frontend_ip_configuration_ids = [
    local.lb_feconfig,
  ]
}






