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

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for the Bastion subnet"
  type        = list(string)
  default     = ["10.1.0.0/26"]
}

variable "appgw_subnet_prefix" {
  description = "Address prefix for the Application Gateway subnet"
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

variable "vm_subnet_prefix" {
  description = "Address prefix for the VM subnet"
  type        = list(string)
  default     = ["10.1.2.0/24"]
}

variable "vm_admin_username" {
  description = "Admin username for the Windows VM"
  type        = string
  default     = "azureadmin"
}

variable "vm_admin_password" {
  description = "Admin password for the Windows VM"
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
