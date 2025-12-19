variable "environment_prefix" {
  description = "Prefix for the environment"
  type        = string
  default     = "dev"
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

variable "vm_admin_password" {
  description = "Admin password for the Windows VM (must meet Azure complexity requirements)"
  type        = string
  sensitive   = true
}

variable "ssl_certificate_data" {
  description = "Base64 encoded PFX used by the Application Gateway listener"
  type        = string
  sensitive   = true
}

variable "ssl_certificate_password" {
  description = "Password that protects the PFX payload"
  type        = string
  sensitive   = true
}
