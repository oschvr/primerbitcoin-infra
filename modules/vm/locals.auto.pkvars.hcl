// Canonical Ubuntu 22.04 minimal 
// https://docs.oracle.com/en-us/iaas/images/image/1891e941-738f-4c8f-bdcb-d63ebac9f0be/

locals {
    base_image_id = "ocid1.image.oc1.uk-london-1.aaaaaaaabe4bbnwk4r72e6xytexsrranv5v6lkaae3yvudn32p36oul5ch3q" //Canonical-Ubuntu-22.04-Minimal-aarch64-2023.03.21-0

    compartment_id = "ocid1.tenancy.oc1..aaaaaaaam62jf3kca2gz5i46fagbaymp5masg7j5p36k4fpothm4gdw5yv3a" //root compartment
    
    timestamp = regex_replace(timestamp(), "[- TZ:]", "")
    date      = formatdate("DD-MM-YYYY", timestamp())

    freeform_tags = {
        "environment" = "prod"
        "terraformed" = "please do not modify manually"
    }
}
