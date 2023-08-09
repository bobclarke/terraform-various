
resource "azurerm_databricks_access_connector" "adac" {
  name                = "databricks-automation-test"
  resource_group_name = var.rg_name
  location            = var.rg_location
  identity {
    type = "SystemAssigned"
  }
}


