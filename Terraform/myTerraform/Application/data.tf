data "azurerm_key_vault" "kv" {
  name                = "${module.config.azure_keyvault}001"
  resource_group_name = "${module.config.azure_resource_group}001"
}

data "azurerm_subnet" "sub" {
  name = "${module.config.azure_virtual_subnet}"
  virtual_network_name = "${module.config.azure_virtual_network}001"
  resource_group_name = "${module.config.azure_network_resource_group}001"
}

data "azurerm_resource_group" "dv1" {
  name = "${module.config.azure_resource_group}001"
}

# data "tf_remote_state" "common" {
#   backend = "azurerm"
#   config = {
#     storage_account_name = "thecrypt"
#     container_name       = "tfstate"
#     key                  = "dev/common.tfstate"
#   } 
# }

data "azurerm_client_config" "current" {}
