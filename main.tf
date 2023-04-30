provider "oci" {
  config_file_profile = var.config_profile
  region              = var.region
}

module "network" {
  source = "./modules/vcn"
  display_name = "${var.app_name}_vcn"
  compartment_id = var.compartment_id
}