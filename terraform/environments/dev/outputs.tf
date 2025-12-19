output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.acs_project.resource_group_name
}

output "communication_service_id" {
  description = "ID of the Azure Communication Service"
  value       = module.acs_project.communication_service_id
}

output "communication_service_primary_connection_string" {
  description = "Primary connection string for Azure Communication Service"
  value       = module.acs_project.communication_service_primary_connection_string
  sensitive   = true
}

output "email_domain_from_sender" {
  description = "The domain that can be used as a sender address"
  value       = module.acs_project.email_domain_from_sender
}

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.acs_project.application_gateway_public_ip
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host"
  value       = module.acs_project.bastion_public_ip
}

output "vm_name" {
  description = "Name of the Windows VM"
  value       = module.acs_project.vm_name
}

output "vm_private_ip" {
  description = "Private IP address of the Windows VM"
  value       = module.acs_project.vm_private_ip
}

output "vm_admin_username" {
  description = "Admin username for the Windows VM"
  value       = module.acs_project.vm_admin_username
}
