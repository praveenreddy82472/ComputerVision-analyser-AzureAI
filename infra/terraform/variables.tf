variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
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

variable "resource_group_name" {
  description = "Existing Azure Resource Group name to deploy into"
  type        = string
}
