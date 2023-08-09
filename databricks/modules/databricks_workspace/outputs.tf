output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "rg_location" {
  value = azurerm_resource_group.rg.location
}

output "databricks_workspace_id" {
  value = azurerm_databricks_workspace.dbws.workspace_id
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.dbws.workspace_url}/"
}