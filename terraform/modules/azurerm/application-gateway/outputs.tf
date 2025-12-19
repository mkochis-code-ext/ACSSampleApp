output "id" {
  description = "The ID of the Application Gateway"
  value       = azurerm_application_gateway.appgw.id
}

output "name" {
  description = "The name of the Application Gateway"
  value       = azurerm_application_gateway.appgw.name
}

output "public_ip_address" {
  description = "The public IP address of the Application Gateway"
  value       = length(azurerm_public_ip.appgw_pip) > 0 ? azurerm_public_ip.appgw_pip[0].ip_address : null
}

output "private_ip_address" {
  description = "The private IP address of the Application Gateway"
  value       = azurerm_application_gateway.appgw.frontend_ip_configuration[0].private_ip_address
}

output "backend_address_pool_ids" {
  description = "List of backend address pool IDs"
  value       = azurerm_application_gateway.appgw.backend_address_pool[*].id
}
