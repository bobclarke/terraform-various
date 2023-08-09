module "databricks_workspace" {
  source = "./modules/databricks_workspace"
}

module "databricks_ac" {
  source      = "./modules/databricks_ac"
  rg_name     = module.databricks_workspace.rg_name
  rg_location = module.databricks_workspace.rg_location
}

module "managed_identity" {
  source      = "./modules/managed_identity"
  rg_name     = module.databricks_workspace.rg_name
  rg_location = module.databricks_workspace.rg_location
}

module "unity_catalog_storage" {
  source                       = "./modules/unity_catalogue_storage"
  rg_name                      = module.databricks_workspace.rg_name
  rg_location                  = module.databricks_workspace.rg_location
  #unity_catalogue_principal_id = module.databricks_ac.unity_catalogue_principal_id
  unity_catalogue_principal_id = module.managed_identity.managed_identity_principal_id
}





# module "databricks_metastore" {
#   source                       = "./modules/databricks_metastore"
#   unity_catalogue_name         = module.unity_catalog_storage.unity_catalogue_name
#   unity_catalogue_principal_id = module.databricks_ac.unity_catalogue_principal_id
#   databricks_workspace_id      = module.databricks_workspace.databricks_workspace_id
#   databricks_host              = module.databricks_workspace.databricks_host
# }

