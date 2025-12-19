locals {
  acs_primary_connection_string = nonsensitive(azurerm_communication_service.acs.primary_connection_string)
  acs_endpoint_with_prefix      = regex("endpoint=[^;]+", local.acs_primary_connection_string)
  acs_endpoint_url              = trimprefix(local.acs_endpoint_with_prefix, "endpoint=")
}

output "id" {
  description = "ID of the Azure Communication Service"
  value       = azurerm_communication_service.acs.id
}

output "name" {
  description = "Name of the Azure Communication Service"
  value       = azurerm_communication_service.acs.name
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_communication_service.acs.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "Secondary connection string"
  value       = azurerm_communication_service.acs.secondary_connection_string
  sensitive   = true
}

output "primary_key" {
  description = "Primary access key"
  value       = azurerm_communication_service.acs.primary_key
  sensitive   = true
}

output "secondary_key" {
  description = "Secondary access key"
  value       = azurerm_communication_service.acs.secondary_key
  sensitive   = true
}

output "endpoint" {
  description = "HTTPS endpoint for the communication service"
  value       = trimsuffix(local.acs_endpoint_url, "/")
}
