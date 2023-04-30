
resource "oci_core_vcn" "vcn" {

  compartment_id = var.compartment_id

  cidr_blocks = var.cidr_blocks

  display_name = var.display_name

  # freeform_tags = locals.freeform_tags
}
