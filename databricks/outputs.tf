output "databricks_workspace_id" {
  value = module.databricks_workspace.databricks_workspace_id
}

output "databricks_host" {
  value = module.databricks_workspace.databricks_host
}


output "access_connector_principal_id" {
  value = module.databricks_ac.access_connector_principal_id
}

output "access_connector_identity" {
  value = module.databricks_ac.access_connector_identity
}

# output "rg_name" {
#   value = module.rg_test.rg_name
# }