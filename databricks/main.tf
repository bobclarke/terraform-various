
# Create a DataBricks workspace
module "databricks_workspace" {
  source = "./modules/databricks_workspace"
}

# Create a managed identity for the access connector
# module "managed_identity" {
#   source                        = "./modules/managed_identity"
#   rg_name                       = module.databricks_workspace.rg_name
#   rg_location                   = module.databricks_workspace.rg_location
# }

# Create an access connector and associate the managed identity created above with it
module "databricks_ac" {
  source                        = "./modules/databricks_ac"
  rg_name                       = module.databricks_workspace.rg_name
  rg_location                   = module.databricks_workspace.rg_location
}

# Create the storage account for the Unity Catalogue and associate the identity with it.
module "unity_catalog_storage" {
  source                        = "./modules/unity_catalogue_storage"
  rg_name                       = module.databricks_workspace.rg_name
  rg_location                   = module.databricks_workspace.rg_location
  access_connector_principal_id = module.databricks_ac.access_connector_principal_id
  access_connector_id           = module.databricks_ac.access_connector_id
}