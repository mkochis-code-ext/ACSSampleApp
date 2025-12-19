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
locals {
  appgw_private_ip = var.appgw_private_ip_address != null ? var.appgw_private_ip_address : cidrhost(var.appgw_subnet_prefix[0], 4)
}

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

# Virtual Network with subnets for Application Gateway, Bastion, and VM
module "virtual_network" {
  source = "../modules/azurerm/virtual-network"

  name                = "vnet-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
  
  subnets = {
    appgw = {
      name             = "AppGatewaySubnet"
      address_prefixes = var.appgw_subnet_prefix
    }
    bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = var.bastion_subnet_prefix
    }
    vm = {
      name             = "VmSubnet"
      address_prefixes = var.vm_subnet_prefix
    }
  }
  
  tags = var.tags
}

# Restrict inbound traffic to Application Gateway subnet
resource "azurerm_network_security_group" "appgw" {
  name                = "nsg-appgw-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "Allow-GatewayManager"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                        = "Allow-VMSubnet-HTTPS"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    source_address_prefixes     = var.vm_subnet_prefix
    destination_address_prefix  = "*"
    destination_port_ranges     = ["443"]
  }
}

resource "azurerm_subnet_network_security_group_association" "appgw" {
  subnet_id                 = module.virtual_network.subnet_ids["appgw"]
  network_security_group_id = azurerm_network_security_group.appgw.id
}

# Restrict VM access to Azure Bastion subnet only
resource "azurerm_network_security_group" "vm" {
  name                = "nsg-vm-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                        = "Allow-Bastion-RDP"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    source_address_prefixes     = var.bastion_subnet_prefix
    destination_address_prefix  = "*"
    destination_port_ranges     = ["3389"]
  }
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = module.virtual_network.subnet_ids["vm"]
  network_security_group_id = azurerm_network_security_group.vm.id
}

# Application Gateway (for ACS endpoint routing)
module "application_gateway" {
  source = "../modules/azurerm/application-gateway"

  name                = "appgw-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.virtual_network.subnet_ids["appgw"]
  enable_public_frontend = var.enable_public_frontend
  private_ip_address     = local.appgw_private_ip
  
  # ACS Communication Service endpoint as backend
  backend_fqdns = [
    replace(replace(module.communication_service.endpoint, "https://", ""), "/", "")
  ]
  
  sku_name  = var.appgw_sku_name
  sku_tier  = var.appgw_sku_tier
  capacity  = var.appgw_capacity
  
  # For demo purposes - using self-signed cert
  ssl_certificate_data     = var.ssl_certificate_data
  ssl_certificate_password = var.ssl_certificate_password
  
  tags = var.tags
}

# Azure Bastion Host (for secure VM access)
module "bastion_host" {
  source = "../modules/azurerm/bastion-host"

  name                = "bastion-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.virtual_network.subnet_ids["bastion"]
  sku                 = var.bastion_sku
  
  tags = var.tags
}

# Windows VM (to run PowerShell script)
module "windows_vm" {
  source = "../modules/azurerm/windows-vm"

  name                = "vm-${var.workload}-${var.environment_prefix}-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.virtual_network.subnet_ids["vm"]
  
  vm_size                      = var.vm_size
  admin_username               = var.vm_admin_username
  admin_password               = var.vm_admin_password
  computer_name                = substr(replace("vm${var.workload}${var.environment_prefix}${var.suffix}", "-", ""), 0, 15)
  image_publisher              = var.image_publisher
  image_offer                  = var.image_offer
  image_sku                    = var.image_sku
  image_version                = var.image_version
  os_disk_storage_account_type = var.os_disk_storage_account_type
  install_powershell_modules   = true
  
  tags = var.tags
}
