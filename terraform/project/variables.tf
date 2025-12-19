variable "location" {
  description = "Azure region (for reference, ACS uses data_location)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}

variable "suffix" {
  description = "workload suffix"
  type = string
}

variable "environment_prefix" {
  description = "Name of the environment"
  type    = string
}

variable "workload" {
  description = "Name of the workload"
  type = string
}

variable "data_location" {
  description = "Data location for Azure Email Service"
  type        = string
  default     = "United States"
}

variable "email_domain_name" {
  description = "The name of the email domain (e.g., 'AzureManagedDomain' for Azure managed domain or custom domain name)"
  type        = string
  default = "AzureManagedDomain"
}

variable "domain_management" {
  description = "The domain management type (AzureManaged or CustomerManaged)"
  type        = string
  default     = "AzureManaged"
  
  validation {
    condition     = contains(["AzureManaged", "CustomerManaged"], var.domain_management)
    error_message = "domain_management must be either 'AzureManaged' or 'CustomerManaged'."
  }
}

# Networking variables
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "appgw_subnet_prefix" {
  description = "Address prefix for Application Gateway subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for Azure Bastion subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "vm_subnet_prefix" {
  description = "Address prefix for VM subnet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

# Application Gateway variables
variable "appgw_sku_name" {
  description = "SKU name for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "appgw_sku_tier" {
  description = "SKU tier for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "appgw_capacity" {
  description = "Capacity for Application Gateway"
  type        = number
  default     = 2
}

variable "enable_public_frontend" {
  description = "Whether to create a public listener on the Application Gateway"
  type        = bool
  default     = false
}

variable "appgw_private_ip_address" {
  description = "Optional static private IP for the Application Gateway frontend"
  type        = string
  default     = null
}

variable "ssl_certificate_data" {
  description = "SSL certificate data (base64 encoded PFX) for Application Gateway"
  type        = string
  sensitive   = true
}

variable "ssl_certificate_password" {
  description = "SSL certificate password for Application Gateway"
  type        = string
  sensitive   = true

  validation {
    condition = length(trimspace(var.ssl_certificate_data)) > 0 && length(trimspace(var.ssl_certificate_password)) > 0
    error_message = "Provide both ssl_certificate_data and ssl_certificate_password (use Generate-AppGatewayCert.ps1 to create values)."
  }
}

# Bastion variables
variable "bastion_sku" {
  description = "SKU for Azure Bastion"
  type        = string
  default     = "Basic"
}

# VM variables
variable "vm_size" {
  description = "Size of the Windows VM"
  type        = string
  default     = "Standard_B2ms"
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

variable "image_publisher" {
  description = "Marketplace publisher for the Windows VM image"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "image_offer" {
  description = "Marketplace offer for the Windows VM image"
  type        = string
  default     = "WindowsServer"
}

variable "image_sku" {
  description = "Marketplace SKU for the Windows VM image"
  type        = string
  default     = "2022-Datacenter"
}

variable "image_version" {
  description = "Marketplace image version for the Windows VM"
  type        = string
  default     = "latest"
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for OS disk"
  type        = string
  default     = "Premium_LRS"
}