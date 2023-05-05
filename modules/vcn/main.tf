
resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  cidr_blocks    = var.cidr_blocks
  display_name   = "${var.display_name}_vcn"

}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  display_name   = "${var.display_name}_internet_gateway"
  vcn_id         = oci_core_vcn.vcn.id
  freeform_tags  = var.freeform_tags
}

resource "oci_core_route_table" "internet_gateway_route_table" {
  compartment_id = var.compartment_id
  display_name   = "${var.display_name}_internet_gateway_route_table"
  vcn_id         = oci_core_vcn.vcn.id
  freeform_tags  = var.freeform_tags
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

data "oci_core_dhcp_options" "dhcp_options" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_subnet" "subnets" {
  for_each                  = var.subnets
  cidr_block                = each.value.cidr_block
  compartment_id            = var.compartment_id
  vcn_id                    = oci_core_vcn.vcn.id
  display_name              = lookup(each.value, "name", each.key)
  route_table_id            = oci_core_route_table.internet_gateway_route_table.id
  freeform_tags             = var.freeform_tags
}
