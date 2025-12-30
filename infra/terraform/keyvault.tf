# keyvault.tf

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = "${local.prefix}-kv"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = "standard"

  soft_delete_retention_days = 30
  purge_protection_enabled   = true

  # RBAC (recommended)
  rbac_authorization_enabled = true

  tags = var.tags
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.acr_pull.principal_id
}


resource "azurerm_role_assignment" "kv_secrets_officer_for_tf" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
