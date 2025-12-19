output "id" {
  description = "The ID of the Windows VM"
  value       = azurerm_windows_virtual_machine.vm.id
}

output "name" {
  description = "The name of the Windows VM"
  value       = azurerm_windows_virtual_machine.vm.name
}

output "private_ip_address" {
  description = "The private IP address of the VM"
  value       = azurerm_network_interface.nic.private_ip_address
}

output "admin_username" {
  description = "The admin username for the VM"
  value       = azurerm_windows_virtual_machine.vm.admin_username
}

output "identity_principal_id" {
  description = "The principal ID of the system assigned identity"
  value       = azurerm_windows_virtual_machine.vm.identity[0].principal_id
}
