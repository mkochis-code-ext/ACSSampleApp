output "id" {
  description = "ID of the Email Domain"
  value       = azurerm_email_communication_service_domain.domain.id
}

output "name" {
  description = "Name of the Email Domain"
  value       = azurerm_email_communication_service_domain.domain.name
}

output "from_sender_domain" {
  description = "The domain that can be used as a sender address"
  value       = azurerm_email_communication_service_domain.domain.from_sender_domain
}

output "mail_from_sender_domain" {
  description = "The mail from sender domain"
  value       = azurerm_email_communication_service_domain.domain.mail_from_sender_domain
}

output "verification_records" {
  description = "DNS verification records (for custom domains)"
  value       = azurerm_email_communication_service_domain.domain.verification_records
}
