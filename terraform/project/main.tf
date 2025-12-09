# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "ws" {
  name                = "law-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Azure Communication Service Module
module "communication_service" {
  source = "../modules/azurerm/communication-service"

  name                = "acs${var.workload}${var.environment_prefix}${var.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  data_location       = var.data_location
  tags                = var.tags
  log_analytics_workspace_id = azurerm_log_analytics_workspace.ws.id
}

# Azure Email Service Module
module "email_service" {
  source = "../modules/azurerm/email-service"

  name                = "es${var.workload}${var.environment_prefix}${var.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  data_location       = var.data_location
  tags                = var.tags
}

# Azure Email Domain Module
module "email_domain" {
  source = "../modules/azurerm/email-domain"

  domain_name       = var.email_domain_name
  email_service_id  = module.email_service.id
  domain_management = var.domain_management
  tags              = var.tags
}

# Link Email Domain to Communication Service
module "email_domain_association" {
  source = "../modules/azurerm/email-domain-association"

  communication_service_id = module.communication_service.id
  email_domain_id          = module.email_domain.id
}
