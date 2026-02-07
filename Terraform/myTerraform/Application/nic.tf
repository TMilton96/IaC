# Create nic for first vm
resource "azurerm_network_interface" "vm1" {
  name                          = "${module.config.azure_network_interface}001"
  location                      = var.location
  resource_group_name           = "${module.config.azure_resource_group}001"
#   enable_accelerated_networking = false
  tags                          = merge(module.config.azure_tags, { "function" = "Web1Nic" })

  ip_configuration {
    name                          = "${module.config.azure_network_interface_configuration}001"
    subnet_id                     = data.azurerm_subnet.sub.id
    private_ip_address_allocation = var.ip_allocation
  }
}