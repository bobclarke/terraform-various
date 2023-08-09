
resource "databricks_metastore" "metastore" {
  name = "automation_test_metastore"
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    var.unity_catalogue_name,
    var.unity_catalogue_name)
  force_destroy = true
}

resource "databricks_metastore_data_access" "metastore_data_access" {
  metastore_id = databricks_metastore.metastore.id
  name         = "automation-test-access"
  azure_managed_identity {
    access_connector_id = var.unity_catalogue_principal_id
  }

  is_default = true
}

resource "databricks_metastore_assignment" "this" {
  workspace_id         = var.databricks_workspace_id
  metastore_id         = databricks_metastore.metastore.id
  default_catalog_name = "automation_test_catalogue"
}

