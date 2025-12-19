variable "name" {
  description = "The name of the Windows VM"
  type        = string
}

variable "location" {
  description = "The Azure region where the VM will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for the VM"
  type        = string
}

variable "vm_size" {
  description = "The size of the VM"
  type        = string
  default     = "Standard_B2ms"
}

variable "computer_name" {
  description = "Optional computer name (max 15 chars, letters/numbers only). Defaults to a truncated version of name."
  type        = string
  default     = null
}

variable "admin_username" {
  description = "The admin username for the VM"
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "The admin password for the VM"
  type        = string
  sensitive   = true
}

variable "image_publisher" {
  description = "Marketplace publisher for the VM image"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "image_offer" {
  description = "Marketplace offer for the VM image"
  type        = string
  default     = "WindowsServer"
}

variable "image_sku" {
  description = "Marketplace SKU for the VM image"
  type        = string
  default     = "2022-Datacenter"
}

variable "image_version" {
  description = "Marketplace image version"
  type        = string
  default     = "latest"
}

variable "os_disk_storage_account_type" {
  description = "The storage account type for the OS disk"
  type        = string
  default     = "Standard_LRS"
}

variable "install_powershell_modules" {
  description = "Whether to install PowerShell modules (Az module)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
