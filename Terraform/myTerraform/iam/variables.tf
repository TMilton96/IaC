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

variable "upn_domain" {
  type = string
}

# variable "users" {
#   description = "Azure AD users to create"
#   type = map(object({
#     display_name = string
#     user_principal_name = string
#     mail_nickname = string
#   }))
# }

variable "groups" {
  type = map(object({
    display_name     = string
    description      = string
    security_enabled = bool
  }))
}

variable "sre_users" {
  type = map(object({
    display_name     = string
    user_principal_name = string
    description      = string
    security_enabled = bool
  }))
}

variable "devops_users" {
  type = map(object({
    display_name     = string
    user_principal_name = string
    description      = string
    security_enabled = bool
  }))
}