variable "location" {
  description = "Azure resource region"
  type        = string 
}

variable "vm1_size" {
  description = "Virtual machine size"
  type = string
}

variable "vm1_image_publisher" {
  description = "Machine image publisher"
  type = string
}

variable "vm1_image_offer" {
  description = "Machine image offer"
  type = string
}

variable "vm1_image_sku" {
  description = "Image sku"
  type = string
}

variable "vm1_image_version" {
  description = "Image version"
  type = string
}

variable "vm1_disk_caching" {
  description = "Disk caching"
  type = string
  default = "None"
}

variable "vm1_disk_create_option" {
  description = "Disk creation"
  type = string
}

variable "vm1_managed_disk_type" {
  description = "Disk type"
  type = string
}

variable "vm1_admin_username" {
  description = "Machin admin username"
  type = string
  default = "Admin"
}

variable "region" {
  type = string
  default = "westus"
}

variable "point_of_contact" {
  type = string
  default = "tanner.j.milton@gmail.com"
}

variable "environment" {
  type = string
}

variable "ip_allocation" {
  type = string
}

variable "sub_id" {
  type = string
}
