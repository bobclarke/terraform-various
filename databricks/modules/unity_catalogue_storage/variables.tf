variable "rg_name" {
    description = "The name of the resource group in which to create the Databricks workspace."
    type        = string
}

variable "rg_location" {
    description = "The location of the resource group in which to create the Databricks workspace."
    type        = string
}

variable "access_connector_principal_id" {}

variable "access_connector_id" {}

variable "adls_details" {
  description = "map of storage account details"
  default = [
    {
      "adls_azure_lock_enabled": "1",
      "adls_filesystems": [
        {
          "name": "unity",
          "paths": []
        }
      ],
      "adls_firewall": "Allow",
      "adls_name": "unity",
      "adls_sftp_enabled": true,
      "adls_soft_delete_in_days": "1",
      "adls_storage_blob_data_contributor": [],
      "adls_storage_blob_data_reader": [],
      "adls_vnet_rules": []
    }
  ]
}

