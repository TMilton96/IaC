terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.59.0"
    }
  }

  backend "azurerm" {
    storage_account_name = "thecrypt"
    container_name       = "tfstate"
    key                  = "dev/terraform.app.tfstate"
    use_azuread_auth     = true
    subscription_id      = "020c021a-8127-4cc1-bc3b-8c45cf22c0be"
    tenant_id            = "f449c21a-82f4-4e8c-b2ed-f9db5820ab6d"
  }

}
