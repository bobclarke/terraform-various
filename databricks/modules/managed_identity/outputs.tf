output "managed_identity_principal_id" {
  value = azurerm_user_assigned_identity.managed_identity.client_id
}