resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = "databricks-automation-test"
  location            = var.rg_location
  resource_group_name = var.rg_name
}


