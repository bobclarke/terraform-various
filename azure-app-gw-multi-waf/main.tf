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

variable "resource_group" {
  default = "xyz"
}


//===================================================================
// Provider setup 
//===================================================================
# provider "azurerm" {
#   version = ">= 2.41.0"
#   subscription_id = var.subscription_id
#   client_id       = var.client_id
#   client_secret   = var.client_secret
#   tenant_id       = var.tenant_id
#   features {
#   }
# }

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.33.0"
    }
  }
}

provider "azurerm" {
  features {}
}


//===================================================================
// Resource Group
//===================================================================
resource "azurerm_resource_group" "example" {
  name     = var.resource_group
  location = "West Europe"
}



//===================================================================
// VNETs
//===================================================================
resource "azurerm_virtual_network" "network" {
  name                = "pl-endpoint-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}


//===================================================================
// Subnets
//===================================================================
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.pl-endpoint-network.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_endpoint_network_policies = true
}


//===================================================================
// Application Gateway
//===================================================================
locals {
  backend_address_pool_name      = "aagw-beap"
  frontend_port_name             = "aagw-feport"
  frontend_ip_configuration_name = "aagw-feip"
  http_setting_name              = "aagw-be-settings"
  listener_name                  = "aagw-listener"
  request_routing_rule_name      = "aagw-rule"
  redirect_configuration_name    = "aagw-redirect"
}

resource "azurerm_subnet" "pl-endpoint-subnet-aagw-fe" {
  name                 = "pl-endpoint-subnet-aagw-fe"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.pl-endpoint-network.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "pl-endpoint-nsg-aagw-fe" {
  name                = "pl-endpoint-nsg-aagw-fe"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "all-ports"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg-assc-aagw-fe" {
  subnet_id                 = azurerm_subnet.pl-endpoint-subnet-aagw-fe.id
  network_security_group_id = azurerm_network_security_group.pl-endpoint-nsg-aagw-fe.id
}

resource "azurerm_public_ip" "pl-endpoint-aagw-pip" {
  name                = "pl-endpoint-aagw-pip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "pl-endpoint-aagw" {
  name                = "aagw"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "pl-endpoint-aagw-ip-configuration"
    subnet_id = azurerm_subnet.pl-endpoint-subnet-aagw-fe.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pl-endpoint-aagw-pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = ""
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

