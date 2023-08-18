output "access_connector_principal_id" {
  value = azurerm_databricks_access_connector.adac.identity[0].principal_id
}

output "access_connector_identity" {
  value = azurerm_databricks_access_connector.adac.identity
}

output "access_connector_id" {
  value = azurerm_databricks_access_connector.adac.identity[0].identity_ids
}

