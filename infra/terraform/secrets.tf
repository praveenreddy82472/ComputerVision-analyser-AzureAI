variable "azure_vision_endpoint" {
  type      = string
  sensitive = true
}

variable "azure_vision_key" {
  type      = string
  sensitive = true
}

variable "azure_openai_endpoint" {
  type      = string
  sensitive = true
}

variable "azure_openai_api_key" {
  type      = string
  sensitive = true
}

variable "azure_openai_deployment" {
  type      = string
  sensitive = true
}

variable "docintel_endpoint" {
  type      = string
  sensitive = true
}

variable "docintel_key" {
  type      = string
  sensitive = true
}

variable "azure_storage_connection_string" {
  type      = string
  sensitive = true
}

variable "azure_storage_container" {
  type      = string
  sensitive = true
}

resource "azurerm_key_vault_secret" "azure_storage_connection_string" {
  name         = "azure-storage-connection-string"
  value        = var.azure_storage_connection_string
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

resource "azurerm_key_vault_secret" "azure_vision_endpoint" {
  name         = "azure-vision-endpoint"
  value        = var.azure_vision_endpoint
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

resource "azurerm_key_vault_secret" "azure_vision_key" {
  name         = "azure-vision-key"
  value        = var.azure_vision_key
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}


# ---------- OpenAI ----------
resource "azurerm_key_vault_secret" "azure_openai_endpoint" {
  name         = "azure-openai-endpoint"
  value        = var.azure_openai_endpoint
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

resource "azurerm_key_vault_secret" "azure_openai_api_key" {
  name         = "azure-openai-api-key"
  value        = var.azure_openai_api_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

resource "azurerm_key_vault_secret" "azure_openai_deployment" {
  name         = "azure-openai-deployment"
  value        = var.azure_openai_deployment
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

# ---------- Document Intelligence ----------
resource "azurerm_key_vault_secret" "docintel_endpoint" {
  name         = "docintel-endpoint"
  value        = var.docintel_endpoint
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

resource "azurerm_key_vault_secret" "docintel_key" {
  name         = "docintel-key"
  value        = var.docintel_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

# ---------- Storage container ----------
resource "azurerm_key_vault_secret" "azure_storage_container" {
  name         = "azure-storage-container"
  value        = var.azure_storage_container
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}


# ---------- Cosmos DB ----------
resource "azurerm_key_vault_secret" "cosmos_endpoint" {
  name         = "cosmos-endpoint"
  value        = var.cosmos_endpoint
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

resource "azurerm_key_vault_secret" "cosmos_key" {
  name         = "cosmos-key"
  value        = var.cosmos_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

resource "azurerm_key_vault_secret" "cosmos_db_name" {
  name         = "cosmos-db-name"
  value        = var.cosmos_db_name
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

resource "azurerm_key_vault_secret" "cosmos_container_name" {
  name         = "cosmos-container-name"
  value        = var.cosmos_container_name
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_secrets_officer_for_tf]
}

