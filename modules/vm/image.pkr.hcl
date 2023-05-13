packer {
    required_plugins {
      oracle = {
        source = "github.com/hashicorp/oracle"
        version = ">= 1.0.3"
      }
    }
}


locals {
    base_image_id = "ocid1.image.oc1.uk-london-1.aaaaaaaa6dm37s6if3tdqv47jfdl6cn3alsfcidntmku6mwgzujtwz3kijmq"

    shape = "VM.Standard.E2.1.Micro"

    compartment_id = "ocid1.compartment.oc1..aaaaaaaa4xcpuhgrelfcpchgektpwaegyugprsqlork2cov6chjg5u3orgwa" //prod compartment

    subnet_ocid = "ocid1.subnet.oc1.uk-london-1.aaaaaaaatsvmhhvqoidoxynsspz5o4yop77vfrk755kwuucw3kispzeob3gq"
    
    availability_domain = "QRBX:UK-LONDON-1-AD-1"

    ssh_username = "ubuntu"

    oci_profile = "oschvr"

    timestamp = regex_replace(timestamp(), "[- TZ:]", "")
    date      = formatdate("DD_MM_YYYY", timestamp())

    freeform_tags = {
        "environment" = "prod"
        "terraformed" = "please do not modify manually"
    }
}


source "oracle-oci" "ubuntu" {

    access_cfg_file_account = local.oci_profile

    compartment_ocid = local.compartment_id
    
    availability_domain = local.availability_domain
    
    base_image_ocid = local.base_image_id
    
    image_name = "pkr_primerbitcoin_${local.date}"
    
    instance_name = "primerbitcoin_image_template"
    
    shape = local.shape
    
    subnet_ocid = local.subnet_ocid
    
    ssh_username = local.ssh_username
   
}

build {

    sources = [
        "source.oracle-oci.ubuntu"
    ]

    provisioner "file" {
        source = "./provisioner.sh"
        destination = "~/provisioner.sh"
    }

    provisioner "shell" {
        remote_folder = "~"
        inline = [
            "sudo bash ~/provisioner.sh",
            "rm ~/provisioner.sh"
        ]
    }
}