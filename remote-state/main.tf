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

//===================================================================
// Resource Group
//===================================================================
resource "azurerm_resource_group" "example" {
  name     = "spaniaz-remote-rg"
  location = "West Europe"
}

//===================================================================
// Remote state
//===================================================================
data "terraform_remote_state" "network" {
  backend = "azurerm"

  config {
    storage_account_name = "${data.vault_generic_secret.base_secrets.data["tf_az_backend_storage_account_name"]}"
    container_name       = "${data.vault_generic_secret.base_secrets.data["tf_az_backend_container_name"]}"
    key                  = "base.terraform.tfstateenv:${var.base_parent}"
    resource_group_name  = "${data.vault_generic_secret.base_secrets.data["tf_az_backend_rg_name"]}"

    arm_subscription_id = "${data.vault_generic_secret.base_secrets.data["subscription_id"]}"
    arm_client_id       = "${data.vault_generic_secret.base_secrets.data["azure_client_id"]}"
    arm_client_secret   = "${data.vault_generic_secret.base_secrets.data["azure_client_secret"]}"
    arm_tenant_id       = "${data.vault_generic_secret.base_secrets.data["azure_tenant_id"]}"
  }
} 