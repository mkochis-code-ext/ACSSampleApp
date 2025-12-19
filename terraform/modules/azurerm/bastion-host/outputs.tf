output "id" {
  description = "The ID of the Bastion Host"
  value       = azurerm_bastion_host.bastion.id
}

output "name" {
  description = "The name of the Bastion Host"
  value       = azurerm_bastion_host.bastion.name
}

output "dns_name" {
  description = "The DNS name of the Bastion Host"
  value       = azurerm_bastion_host.bastion.dns_name
}

output "public_ip_address" {
  description = "The public IP address of the Bastion Host"
  value       = azurerm_public_ip.bastion_pip.ip_address
}
