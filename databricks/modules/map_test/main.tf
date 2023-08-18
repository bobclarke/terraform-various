
# If no RG name is provided create a RG
resource "azurerm_resource_group" "rg" {
  count    = var.rg_name == "" ? "1" : "0"
  name     = "static-rg"
  location = "westeurope"
}

# If a RG name is provided use it
data "azurerm_resource_group" "rg" {
  name =  var.rg_name
}
