variable "location" {
  description = "Azure resource region"
  type        = string 
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

variable "sub_id" {
  type = string
}

variable "address_prefixes" {
  type = list(string)
}

variable "address_prefixes_web001" {
  type = list(string)
}

variable "address_space" {
  type = list(string)
}