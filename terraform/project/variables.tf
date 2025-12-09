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