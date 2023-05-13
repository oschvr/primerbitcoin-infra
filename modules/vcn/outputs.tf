output "id" {
  value = oci_core_vcn.vcn.id
}

output "subnets_map" {
  value = {
    for s in oci_core_subnet.subnets : s.display_name => s.id
  }
}


output "subnets_id" {
  value = [
    for s in oci_core_subnet.subnets : s.id
  ]
}

output "ssh_nsg_id" {
  value = oci_core_network_security_group.ssh.id
}