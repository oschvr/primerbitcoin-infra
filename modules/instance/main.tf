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
  compartment_id      = var.compartment_id
  shape               = var.shape
  display_name        = var.display_name

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = var.subnet_id
    nsg_ids          = var.nsg_ids
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    source = "../primerbitcoin/build/primerbitcoin-linux-amd64"
    destination = "/tmp/primerbitcoin"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/primerbitcoin-root")
      host = self.public_ip
    } 
  }

  provisioner "file" {
    source = "../primerbitcoin/.env"
    destination = "/tmp/.env-init"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/primerbitcoin-root")
      host = self.public_ip
    } 
  }

  provisioner "file" {
    source = "../primerbitcoin/application.yaml"
    destination = "/tmp/application.yaml-init"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/primerbitcoin-root")
      host = self.public_ip
    } 
  }

  metadata = {
    user_data           = base64encode(file("./modules/instance/cloud-init.sh"))
    ssh_authorized_keys = <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKSSne/F4dz0r2rJ9U9fXG1vnto4YPzwihxTacK8yO9z oschvr@protonmail.com
  EOF
  }

  freeform_tags = var.freeform_tags
}

resource "oci_core_public_ip" "reserved_ip" {
  compartment_id = var.compartment_id
  lifetime = var.reserved_ip
}