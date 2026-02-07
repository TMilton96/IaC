# Create random password for app vms
resource "random_password" "web_administrator" {
  length           = 64
  special          = true
  lower            = true
  upper            = true
  override_special = "!$#%"
}

# Create secret for web admin password
resource "azurerm_key_vault_secret" "kvs" {
  name         = "${module.config.azure_keyvault_secret}001"
  value        = random_password.web_administrator.result
  key_vault_id = data.azurerm_key_vault.kv.id
}