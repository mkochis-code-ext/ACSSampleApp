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
}