variable "name" {
  description = "The name of the Application Gateway"
  type        = string
}

variable "location" {
  description = "The Azure region where the Application Gateway will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for Application Gateway"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "The SKU tier of the Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "The capacity of the Application Gateway"
  type        = number
  default     = 2
}

variable "enable_public_frontend" {
  description = "Whether to expose the Application Gateway via a public IP"
  type        = bool
  default     = false
}

variable "private_ip_address" {
  description = "Optional static private IP address for the Application Gateway frontend"
  type        = string
  default     = null
}

variable "backend_fqdns" {
  description = "List of backend FQDNs (ACS endpoints)"
  type        = list(string)
}

variable "ssl_certificate_name" {
  description = "Name of the SSL certificate"
  type        = string
  default     = ""
}

variable "ssl_certificate_data" {
  description = "SSL certificate data (base64 encoded PFX)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssl_certificate_password" {
  description = "SSL certificate password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssl_policy_type" {
  description = "SSL policy type (Predefined or Custom)"
  type        = string
  default     = "Predefined"
}

variable "ssl_policy_name" {
  description = "Name of the predefined SSL policy (when ssl_policy_type is Predefined)"
  type        = string
  default     = "AppGwSslPolicy20220101"
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
