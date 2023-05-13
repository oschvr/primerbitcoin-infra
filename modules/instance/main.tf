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
    nsg_ids = var.nsg_ids
  }

  source_details {
    source_id = var.image_id
    source_type = "image"
  }

  metadata = {
    user_data = base64encode(file("./modules/instance/cloud-init.sh"))
    ssh_authorized_keys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCamSEooOgOwZjMKGIHbUTS2ruIlaCQgSlDtEupyVylf0ElbaxMKiL+EaDfIxG36obiiWzENpbAQQ5NTeQr+YKCX37Zl5/mnCHaCO1neRmPZSxzr52PmBqYE2rxYH+66zqkNqia/ZS1l15Y1W1c1UeyUE+bXFYIRGhp+CX4nuTngTsn7aXe225CNKh0Jhg+1ycncO6BWQ1DwCgVdaBhKzY7CLwBdOOYzJF+kk8qse82zFXIMWlRukFDQFkH5D+X51xDMiCa26ssoBGzjwT9XRgbYmBqbt+0y390EHCAXIuYFiCnPAVPQ5MSdsw8FYgYQelpqSO13ssa16AXvQsL5FSziHRuUJvbJ9LocyHVrGUkjlc+Fkli9JPTbY5U91cUn1oNu8DURMteCLgYA9RLvUkYnFwmuPJdMM7oxO0fDUxFO5rEAZIFk5DlKqiF3P2z57vrZXOUTvBR+ZN6wvikHdbgjHiXJ+kvUTsVXWZh1SJA+k4i6oaskfSJkqbfJVJm01LDYoXAmt8ZEeQaGTt4OfIE6G+KsUS9v3AVngpMwSU5vCoYva48r71/bl7UiImNaFlQ3QMlQk452A7iijOw1CJ6w6C+l5N9ZdJ6dtwN3xPZ2liJTpSHpTNsqDUYyhjbt6v0nAU8nB3mx5CE3H6ppwhaQEvygds6lO3EPtD9LW6i2w== oschvr@protonmail.com
  EOF
  }


  freeform_tags = var.freeform_tags
}