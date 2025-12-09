variable "domain_name" {
  description = "The name of the email domain (e.g., 'AzureManagedDomain' for Azure managed domain or custom domain name)"
  type        = string
}

variable "email_service_id" {
  description = "The ID of the Email Communication Service"
  type        = string
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

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
