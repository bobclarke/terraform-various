
resource "azurerm_resource_group" "rg" {
  name     = "int-databricks"
  location = "westeurope"
}


data "azurerm_key_vault" "kvds" {
    name                = "shared-CLZ000175"
    resource_group_name = "CLZ000175-env0-keyvault-rg"
}

data "azurerm_key_vault_secret" "adls_details" {
  key_vault_id = data.azurerm_key_vault.kvds.id
  name         = "adls-details"
}


# resource "azurerm_storage_account" "unity_catalog" {  
#   name                     = "databricksautomationtest"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = vazurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
#   is_hns_enabled           = true
#   identity {
#     type = "SystemAssigned"
#   }
# }

# resource "azurerm_storage_container" "unity_catalog" {
#   name                  = "databricks-automation-test"
#   storage_account_name  = azurerm_storage_account.unity_catalog.name
#   container_access_type = "private"
# }

# resource "azurerm_role_assignment" "sa_role_assignment" {
#   scope                = azurerm_storage_account.unity_catalog.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id = var.access_connector_principal_id
# }


# locals {
#   adls_name = var.adls_name_override != "" ? var.adls_name_override : "unity"
  

#   adls_details = [
#     {
#       "adls_azure_lock_enabled": "1",
#       "adls_filesystems": [
#         {
#           "name": var.adls_name_override != "" ? var.adls_name_override : "unity",
#           "paths": []
#         }
#       ],
#       "adls_firewall": var.adls_details[0].adls_firewall,
#       "adls_name": "unity",
#       "adls_sftp_enabled": true,
#       "adls_soft_delete_in_days": "1",
#       "adls_storage_blob_data_contributor": [],
#       "adls_storage_blob_data_reader": [],
#       "adls_vnet_rules": []
#     }
#   ]  
# }


locals {
  #adls_details = var.adls_details

  # updated_adls_details = {
  #   for adls in local.adls_details: 
  #   adls.adls_name => adls
  # }
  
  # adls_details2 = var.adls_details

  # updated_adls_details2 = {
  #   for k in local.adls_details2: k => "bar"
  # }


  #adls_details = distinct(var.adls_details)
  
  # updated_adls_details = {
  #   for k, v in var.adls_details: k => merge (v, {
  #     adls_name = "new_name"
  #   })
  # }

  # updated_adls_details = {
  #   for k, v in var.adls_details: k => {
  #     adls_name = "new_name"
  #   }
  # }

}


  





# output "updated" {
#   value = { for k, a in local.alerts_settings : k => {
#     alert_name            = a.alert_name
#     resource_id_tomonitor = lookup(local.new_values, k, a.resource_id_tomonitor)
#   } }
# }

# output "updated" {
#   value = { for k, a in local.alerts_settings : k => merge(a, {
#     resource_id_tomonitor = lookup(local.new_values, k, a.resource_id_tomonitor)
#   }) }
# }

