resource "azurerm_email_communication_service_domain" "domain" {
  name              = var.domain_name
  email_service_id  = var.email_service_id
  domain_management = var.domain_management
  tags              = var.tags
}
