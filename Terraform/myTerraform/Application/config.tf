module "config" {
  source           = "../../modules/configuration"
  environment      = var.environment
  region           = var.region
  point_of_contact = var.point_of_contact
}
