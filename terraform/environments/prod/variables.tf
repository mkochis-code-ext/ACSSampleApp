variable "environment_prefix" {
  description = "Prefix for the environment"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "canadacentral"
}

variable "data_location" {
  description = "Data location for Azure Email Service"
  type        = string
  default     = "Canada"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
