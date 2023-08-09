
resource "azurerm_storage_account" "unity_catalog" {
  name                     = "databricksautomationtest"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
  identity {
    type = "UserAssigned"
    identity_ids = [
      var.unity_catalogue_principal_id
    ]
  }
}

resource "azurerm_storage_container" "unity_catalog" {
  name                  = "databricks-automation-test"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

resource "azurerm_role_assignment" "sa_role_assignment" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  //principal_id         = azurerm_databricks_access_connector.unity.identity[0].principal_id
  principal_id         = var.unity_catalogue_principal_id
}



# resource "azurerm_role_assignment" "assign_identity_storage_blob_data_contributor" {
#   scope                = azurerm_storage_account.my_storage_account.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = azurerm_user_assigned_identity.managed_identity.principal_id
# }


