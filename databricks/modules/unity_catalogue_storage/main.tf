
resource "azurerm_storage_account" "unity_catalog" {
  name                     = "databricksautomationtest"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  is_hns_enabled           = true
  identity {
    type = "SystemAssigned"
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
  principal_id = var.access_connector_principal_id
}