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
// Get ingress IP
//===================================================================
data "kubernetes_service" "internal-ingress" {
  metadata {
    name = "nginx-ingress-controller"
    namespace = "ingress"
  }
}

output "internal-ingress-ip" {
  value = data.kubernetes_service.internal-ingress.status.0.load_balancer.0.ingress.0.ip
}


//===================================================================
// Get the LB and subnet ids (we need these for the private link service)
//===================================================================
data "azurerm_lb" "lb" {
  name                = "kubernetes-internal"
  resource_group_name = "MC_eu-az-nft-wal-aks-rg_eu-az-nft-wal_westeurope"
}

locals {
  admin_roles = ["user","admin","guest"]
  admin_members = ["bob","jon","simon"]
  


  admin_bindings = {
    for role in local.admin_roles:
      role => local.admin_members
  }


  ingress_ip = data.kubernetes_service.internal-ingress.status.0.load_balancer.0.ingress.0.ip


  
  test_map = {
    "foo" = {
      "bar" = {
        "gah" = "far"
      }
    }
  }

  ip_map = {
    for ip in local.test_ips:
    ip => "bar"
  }
  
  
  test_ips = ["10.1.1.10","10.1.1.20","10.1.1.30",]


  fe_configs = [
    for fe_config in data.azurerm_lb.lb.frontend_ip_configuration:
    {
      "${fe_config.private_ip_address}" = {
        "details" = {
          "subnet_id" = fe_config.subnet_id
          "load_balancer_frontend_ip_configuration_id" = fe_config.id
        }
      }
    }
  ]

  feconfigs = {
    for feconfig in data.azurerm_lb.lb.frontend_ip_configuration:
      "${feconfig.private_ip_address}" => {
        "subnet_id" = feconfig.subnet_id
        "load_balancer_frontend_ip_configuration_id" = feconfig.id
      }
    }
}

//===================================================================
// Find the LB FE config with the same IP as the ingress and get it's id and subnet 
//===================================================================


 
/* 
output "dump" {
  //value               = data.azurerm_lb.lb.frontend_ip_configuration[*].private_ip_address
  value               = local.fe_configs
}


output "match" {
  value               = local.fe_configs[0]
}
 */



output "feconfigs" {
  value               = local.feconfigs[local.ingress_ip]
}








//===================================================================
// Notes etc
//===================================================================
/* %{ for additionalDomain in local.additionalDomains ~}
    - port:
        number: 443
        name: https-${additionalDomain}-port
        protocol: HTTPS
      hosts:
      - '${additionalDomain}'
      - '*.${additionalDomain}'
      tls:
        credentialName: wildcard-${additionalDomain}-devops-tls
        mode: SIMPLE
%{ endfor ~} */










 /* 
 LOGIC
 Get the IP for the correct igress controller
 This will tell you which Front end config to use (i.e many igress controllers use the same LB) 
 */




