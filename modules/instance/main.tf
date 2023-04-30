// Get all availability domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_ocid
}

// Get default volume backup policies
data "oci_core_volume_backup_policies" "default_backup_policies" {}

// Convert data sources int maps/lists
locals {
  availability_domains = [
    for i in data.oci_identity_availability_domains.ad.availability_domains : i.name
  ]
  backup_policies = {
    for i in data.oci_core_volume_backup_policies.default_backup_policies : i.display_name => i.id
  }
}

// Get subnet data
data "oci_core_subnet" "instance_subnet" {

}


// Create custom oci_core_instance
resource "oci_core_instance" "instance" {

}