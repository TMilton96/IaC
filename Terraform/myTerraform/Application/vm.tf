resource "azurerm_virtual_machine" "vm1" {
  name                  = "${module.config.azure_vm}001"
  location              = var.location
  resource_group_name   = "${module.config.azure_resource_group}001"
  network_interface_ids = [azurerm_network_interface.vm1.id]
  vm_size               = var.vm1_size
  tags                  = merge(module.config.azure_tags, { "function" = "Web1Server" })

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.vm1_image_publisher
    offer     = var.vm1_image_offer
    sku       = var.vm1_image_sku
    version   = var.vm1_image_version
  }
  storage_os_disk {
    name              = "${module.config.azure_disk}001"
    caching           = var.vm1_disk_caching
    create_option     = var.vm1_disk_create_option
    managed_disk_type = var.vm1_managed_disk_type
  }
  os_profile {
    computer_name  = "${module.config.azure_vm}001"
    admin_username = var.vm1_admin_username
    admin_password = random_password.web_administrator.result
  }
  os_profile_linux_config {
    disable_password_authentication = false  
  }
}