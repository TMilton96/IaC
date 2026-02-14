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
    key                  = "dev/terraform.users.tfstate"
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
  source           = "../../modules/configuration"
  environment      = var.environment
  region           = var.region
  point_of_contact = var.point_of_contact
}

locals {
  users = merge(
    var.sre_users,
    var.devops_users
  )
}

#############################
## User creation resources ##
#############################
resource "random_password" "userpass" { # Create a randomized password for each user
  for_each         = local.users
  length           = 64
  special          = true
  lower            = true
  upper            = true
  override_special = "!$#%"
}

resource "azuread_user" "users" {
  for_each = local.users

  display_name        = each.value.display_name
  user_principal_name = "${each.key}@${var.upn_domain}"
  # mail_nickname       = each.value.mail_nickname

  password              = random_password.userpass[each.key].result
  force_password_change = true
}


##############################
## group creation resources ##
##############################

resource "azuread_group" "groups" {
  for_each = var.groups

  display_name     = each.value.display_name
  description      = each.value.description
  security_enabled = each.value.security_enabled
}

resource "azuread_group_member" "sre_members" {
  for_each = var.sre_users

  group_object_id  = azuread_group.groups["sre"].object_id
  member_object_id = azuread_user.users[each.key].object_id
}

resource "azuread_group_member" "devops_members" {
  for_each = var.devops_users

  group_object_id  = azuread_group.groups["devops"].object_id
  member_object_id = azuread_user.users[each.key].object_id
}