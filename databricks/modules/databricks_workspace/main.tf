resource "azurerm_resource_group" "rg" {
  name     = "int-databricks-rg"
  location = "West Europe"
}

resource "azurerm_databricks_workspace" "dbws" {
  name                = "databricks-automation-test"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "premium"

  tags = {
    Environment = "Development"
  }
}


