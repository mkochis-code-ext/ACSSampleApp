terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
}

locals {
  suffix = "${random_string.suffix.result}"
  tags = {
    "Environment" = "${var.environment_prefix}"
  }
}

module acs_project {
  source = "../../project"

  environment_prefix = var.environment_prefix
  suffix = local.suffix
  workload = "pltdemo"
  tags = local.tags
  location = var.location
  data_location = var.data_location
  vnet_address_space = var.vnet_address_space
  bastion_subnet_prefix = var.bastion_subnet_prefix
  appgw_subnet_prefix = var.appgw_subnet_prefix
  vm_subnet_prefix = var.vm_subnet_prefix
  vm_admin_username = var.vm_admin_username
  vm_admin_password = var.vm_admin_password
  ssl_certificate_data     = var.ssl_certificate_data
  ssl_certificate_password = var.ssl_certificate_password
}