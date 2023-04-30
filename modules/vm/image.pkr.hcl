

source "oracle-oci" "ubuntu" {
    compartment_ocid = locals.compartment_id
    
    availability_domain = "${AVAILABILITY_DOMAIN}"
    
    base_image_ocid = locals.base_image_id
    
    image_name = var.image_name
    
    instance_name = var.instance_name
    
    shape = var.shape
    
    subnet_ocid = 
    
    ssh_username = locals.ssh_username
    
    freeform_tags = locals.freeform_tags

    user_data_file = "./cloud-init.sh"
}