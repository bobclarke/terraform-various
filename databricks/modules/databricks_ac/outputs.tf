output "unity_catalogue_principal_id" {
  value = azurerm_databricks_access_connector.adac.identity[0].principal_id
}

