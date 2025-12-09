resource "azurerm_communication_service" "acs" {
  name                = var.name
  resource_group_name = var.resource_group_name
  data_location       = var.data_location
  tags                = var.tags
}

module "diagnostic_settings" { 
  source = "../diagnostic_settings"

  name = "diagnostics"
  log_analytics_destination_type = "Dedicated"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  resource_id = azurerm_communication_service.acs.id

}