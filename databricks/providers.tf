terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
    features {
      
    }
    tenant_id = var.tenant_id
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
}

provider "databricks" {
    client_id       = var.client_id
    #client_secret   = var.client_secret
    host = module.databricks_workspace.databricks_host

}



