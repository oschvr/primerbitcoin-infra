// Get all availability domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.compartment_id
}

// Convert data sources int maps/lists
locals {
  availability_domains = [
    for i in data.oci_identity_availability_domains.ad.availability_domains : i.name
  ]
}

// Create custom oci_core_instance
resource "oci_core_instance" "instance" {
  availability_domain = local.availability_domains[0]
  compartment_id = var.compartment_id
  shape = var.shape
  display_name = var.display_name

  create_vnic_details {
    assign_public_ip = true
    subnet_id = var.subnet_id
  }

  source_details {
    source_id = var.image_id
    source_type = "image"
  }

  freeform_tags = var.freeform_tags
}