locals {
  prefix = lower(var.name_prefix)
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}
