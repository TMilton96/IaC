locals {
  
    region_short_name_table = {
    "westeurope"     = "eu01",
    "northeurope"    = "eu02",
    "eastus"         = "na01",
    "eastus2"        = "na02",
    "centralus"      = "na03",
    "westus"         = "na04",
    "northcentralus" = "na05",
    "southcentralus" = "na06",
    "westus2"        = "na07",
    "westcentralus"  = "na08",
    "uksouth"        = "uk01",
    "ukwest"         = "uk02"
  }

  environment_short_name_table = {
  "dev" = "dv"
  }

  region_short_name           = local.region_short_name_table[var.region]
  environment_short_name      = local.environment_short_name_table[var.environment]
  
}

output "azure_tags" {
  value = {
    owner           = var.point_of_contact
    environment     = var.environment
    terraform       = true
  }
}

#########################
#### General outputs ####
#########################
output "environment_short_name" {
  value = local.environment_short_name
}

output "region_short_name" {
  value = local.region_short_name
}

output "azure_resource_group" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-rg"
}


###########################
#### Key Vault outputs ####
###########################
output "azure_keyvault" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}kv"
}

output "azure_keyvault_secret" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}kvs"
}


############################
#### Networking outputs ####
############################
output "azure_network_resource_group" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-netrg"
}

output "azure_virtual_network" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}vnet"
}

output "azure_virtual_subnet" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}subnet"
}

output "azure_nsg" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}nsg"
}

output "azure_public_ip" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}pip"
}

output "azure_bastion_host" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}bstn"
}

output "azure_network_interface" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}nic"
}

output "azure_load_balancer" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-lb"
}

output "azure_load_balancer_rule" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-rule"
}


output "azure_network_security_group" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-nsg"
}

output "azure_lb_backend_address_pool" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-bp"
}

output "azure_health_probe" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-hp"
}

output "azure_network_interface_configuration" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-niccfg"
}

#################################
#### Virtual Machine outputs ####
#################################
output "azure_virtual_machine" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}vm"
}

output "azure_virtual_disk" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}dsk"
}

output "azure_disk" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-disk"
}

output "azure_vm" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}vm"
}




#########################
#### Storage outputs ####
#########################
output "azure_storage_account" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}sa"
}

output "azure_storage_container" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}c"
}

####################################
#### Logging/Monitoring outputs ####
####################################

output "azure_log_analytics_workspace" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-law"
}

output "azure_app_insights" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-ai"
}

output "azure_automation_account" {
  value = "${local.environment_short_name}-tm-${local.region_short_name}-aa"
}
