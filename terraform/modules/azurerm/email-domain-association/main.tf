resource "azurerm_communication_service_email_domain_association" "association" {
  communication_service_id = var.communication_service_id
  email_service_domain_id  = var.email_domain_id
}
