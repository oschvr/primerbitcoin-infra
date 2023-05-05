provider "oci" {
  config_file_profile = var.config_profile
  region              = var.region
}

resource "oci_identity_compartment" "prod" {
  compartment_id = var.tenancy_id
  description    = "${var.compartment_name} compartment for primerbitcoin"
  name           = var.compartment_name
  enable_delete  = false
}

module "network" {
  source         = "./modules/vcn"
  display_name   = var.app_name
  compartment_id = oci_identity_compartment.prod.id
  cidr_blocks    = ["172.16.0.0/16"]
  subnets = {
    public_subnet_1 = {
      name       = "${var.app_name}_public_subnet_1",
      cidr_block = "172.16.1.0/24",
      type       = "public"
    }
    # private_subnet_1 = {
    #     name = "${var.app_name}_private_subnet_1",
    #     cidr_block = "172.16.30.0/24",
    #     type = "private"
    # }
  }

  freeform_tags = var.freeform_tags
}