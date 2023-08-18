output "adls_details" {
  value = jsondecode(data.azurerm_key_vault_secret.adls_details.value)
}

# output "adls_name_override_provided" {
#   value = var.adls_name_override
# }

# output "adls_name_override" {
#   value = var.adls_details[0]["adls_name"]
# }

output "adls_name" {
  value = var.adls_details[0]["adls_name"]
}


# output "local_adls_name" {
#   value = local.adls_name
# }

# output "actual_adls_name" {
#   value = var.adls_details[0]["adls_name"]
# }


# output "updated_adls_details" {
#   value = local.updated_adls_details[0]
# }


