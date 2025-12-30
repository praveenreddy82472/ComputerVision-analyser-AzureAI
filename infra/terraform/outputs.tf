output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "location" {
  value = data.azurerm_resource_group.rg.location
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.law.id
}


output "container_app_environment_id" {
  value = azurerm_container_app_environment.cae.id
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "container_app_name" {
  value = azurerm_container_app.api.name
}

output "container_app_fqdn" {
  value = azurerm_container_app.api.latest_revision_fqdn
}

output "cosmos_db_name" {
  value = var.cosmos_db_name
}

output "cosmos_container_name" {
  value = var.cosmos_container_name
}

output "cosmos_endpoint" {
  value     = var.cosmos_endpoint
  sensitive = true
}

output "cosmos_primary_key" {
  value     = var.cosmos_key
  sensitive = true
}

