variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "name_prefix" {
  description = "Prefix for naming Azure resources (lowercase, no spaces)"
  type        = string
}

variable "resource_group_name" {
  description = "Existing Azure Resource Group name to deploy into"
  type        = string
}

variable "tags" {
  description = "Tags applied to resources"
  type        = map(string)
  default     = {}
}
