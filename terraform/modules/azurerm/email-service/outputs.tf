output "id" {
  description = "ID of the Azure Email Service"
  value       = azurerm_email_communication_service.email.id
}

output "name" {
  description = "Name of the Azure Email Service"
  value       = azurerm_email_communication_service.email.name
}

output "endpoint" {
  description = "Endpoint of the Azure Email Service"
  value       = "https://${azurerm_email_communication_service.email.name}.communication.azure.com"
}
