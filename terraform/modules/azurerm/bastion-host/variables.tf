variable "name" {
  description = "The name of the Azure Bastion Host"
  type        = string
}

variable "location" {
  description = "The Azure region where the Bastion Host will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the AzureBastionSubnet"
  type        = string
}

variable "sku" {
  description = "The SKU of the Bastion Host"
  type        = string
  default     = "Basic"
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
