variable "compartment_id" {
  description = "OCID of compartment where instance will be deployed"
  type        = string
}

variable "app_name" {
  description = "Name of the deployment/app"
  type        = string
}

variable "region" {
  description = "Region to deploy VM to"
  type        = string
}

variable "config_profile" {
  description = "OCI config profile for auth"
  type        = string
}






