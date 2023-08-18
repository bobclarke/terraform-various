variable "tenant_id" {
  description = "The Azure tenant ID."
}

variable "subscription_id" {
  description = "The Azure subscription ID."
}

variable "client_id" {
  description = "The Azure client ID."
}

variable "client_secret" {
  description = "The Azure client secret."
}

variable "adls_details" {
  description = "map of storage account details"
  default = [
    {
      "adls_name": "sa_name",
      "adls_azure_lock_enabled": "1",
      "adls_filesystems": [
        {
          "name": "fsname1",
          "paths": ["fspath1", "fspath2"]
        },
        {
          "name": "fsname2",
          "paths": ["fspath1", "fspath2"]
        }
      ],
      "adls_firewall": "Deny",
      "adls_sftp_enabled": true,
      "adls_soft_delete_in_days": "1",
      "adls_storage_blob_data_contributor": [],
      "adls_storage_blob_data_reader": [],
      "adls_vnet_rules": []
    }
  ]
}
