
module "unity_catalogue_storage" {
  source = "./modules/unity_catalogue_storage"
  adls_details = var.adls_details
}


module "databricks_access_connector" {
  source = "./modules/databricks_access_connector"
}

