# resource "azurerm_role_assignment" "StorageBlobDataContributor" {
#   for_each             = var.adls_enabled == "1" ? { for i in local.adls_contributor_list : "${i.account}" - "${i.id}" => i } : {}
#   scope                = data.azurerm_resource_group.rgds.id
#   role_definition_name = "Storage Blob Data Contributor"
#   principal_id         = each.value.id
# }


variable "adls_details" {
    description = "foo"
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
            "adls_storage_blob_data_contributor": ["1786caa4-4155-4d9a-908f-f7b5a55f4abf", "d0b0b2a9-4b7e-4b1e-8b0a-5b6b7b2b4b4b"],
            "adls_storage_blob_data_reader": [],
            "adls_vnet_rules": []
        }
    ]
}


locals {
    adls_contributor_list = flatten([
        for account in var.adls_details : [
            for contributor in account.adls_storage_blob_data_contributor : {
                id      = contributor
                account = account.adls_name
            }
        ]
    ])
}

# output "adls_contributor_list" {
#     value = local.adls_contributor_list
# }

# output "mymap" {
#     #value = { for i in local.adls_contributor_list : "foo" => i }
#     value = { for i in local.adls_contributor_list : "${i.account} - ${i.id}" => i }

# }

# output "flattened_adls_details" {
#     value = flatten([
#             for account in var.adls_details : [
#                 for contributor in account.adls_storage_blob_data_contributor : {
#                     id      = contributor
#                     account = account.adls_name
#                 }
#             ]
#         ])
#     }

output "adls_details" {
    value = [
            for account in var.adls_details : [
                for contributor in account.adls_storage_blob_data_contributor : {
                    id      = contributor
                    account = account.adls_name
                }
            ]
        ]
    }


