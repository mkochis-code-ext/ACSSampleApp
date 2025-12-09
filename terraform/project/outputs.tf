output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "name_suffix" {
  description = "The generated name suffix (environment-random)"
  value       = var.suffix
}

output "communication_service_id" {
  description = "ID of the Azure Communication Service"
  value       = module.communication_service.id
}

output "communication_service_primary_connection_string" {
  description = "Primary connection string for Azure Communication Service"
  value       = module.communication_service.primary_connection_string
  sensitive   = true
}

output "communication_service_primary_key" {
  description = "Primary key for Azure Communication Service"
  value       = module.communication_service.primary_key
  sensitive   = true
}

output "email_service_id" {
  description = "ID of the Azure Email Service"
  value       = module.email_service.id
}

output "email_service_endpoint" {
  description = "Endpoint for Azure Email Service"
  value       = module.email_service.endpoint
}

output "email_domain_id" {
  description = "ID of the Email Domain"
  value       = module.email_domain.id
}

output "email_domain_from_sender" {
  description = "The domain that can be used as a sender address"
  value       = module.email_domain.from_sender_domain
}

output "email_domain_verification_records" {
  description = "DNS verification records (for custom domains)"
  value       = module.email_domain.verification_records
}
