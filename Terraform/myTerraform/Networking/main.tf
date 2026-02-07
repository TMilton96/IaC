terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.50.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "thecrypt"
    container_name       = "tfstate"
    key                  = "dev/terraform.networking.tfstate"
    use_azuread_auth     = true
    subscription_id      = "020c021a-8127-4cc1-bc3b-8c45cf22c0be"
    tenant_id            = "f449c21a-82f4-4e8c-b2ed-f9db5820ab6d"
  }

}

provider "azurerm" {
  features {}
    subscription_id = var.sub_id
}

module "config" {
  source = "../../modules/configuration"
  region = var.region
  point_of_contact = var.point_of_contact
}

resource "azurerm_resource_group" "netrg1" {
  name = "${module.config.azure_network_resource_group}001"
  location = var.location
  tags     = merge(module.config.azure_tags, {"function" = "${var.environment}NetworkingResourceGroup"})
}

resource "azurerm_network_security_group" "nsg1" {
  name = "${module.config.azure_network_security_group}001"
  location = var.location
  resource_group_name = azurerm_resource_group.netrg1.name
}

resource "azurerm_virtual_network" "vnet1" {
  name = "${module.config.azure_virtual_network}001"
  location = var.location
  resource_group_name = "${module.config.azure_network_resource_group}001"
  address_space       = var.address_space

  subnet {
    name = "${module.config.azure_virtual_subnet}"
    address_prefixes = var.address_prefixes
    security_group = azurerm_network_security_group.nsg1.id
  }

  subnet {
    name = "${module.config.azure_virtual_subnet}-web001"
    address_prefixes = var.address_prefixes_web001
    security_group = azurerm_network_security_group.nsg1.id
  }
}