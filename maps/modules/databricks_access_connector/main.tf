

variable "adls_details" {
  description = "map of storage account details"
  default = [
    {
      "adls_name": "unity",
      "adls_azure_lock_enabled": "1",
      "adls_filesystems": [
        {
          "name": "unity",
          "paths": [""]
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


data "azurerm_key_vault" "kvds" {
    name                = "shared-CLZ000175"
    resource_group_name = "CLZ000175-env0-keyvault-rg"
}

resource "azurerm_key_vault_secret" "keyvault_secret" {
  key_vault_id = data.azurerm_key_vault.kvds.id
  name         = "adls-details"
  value        = jsonencode(var.adls_details)
}

