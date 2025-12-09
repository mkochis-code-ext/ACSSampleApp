variable "name" {
  description = "Name of the Azure Communication Service"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "data_location" {
  description = "Azure region (for reference, ACS uses data_location)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Id of the log_analytics_workspace"
  type        = string
  default = null
}