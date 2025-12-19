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
