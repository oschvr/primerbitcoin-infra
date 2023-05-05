output "id" {
  value = oci_core_vcn.vcn.id
}

output "subnets_map" {
  value = {
    for s in oci_core_subnet.subnets : s.display_name => s.id
  }
}
