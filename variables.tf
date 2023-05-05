variable "tenancy_id" {
  description = "OCID of tenancy where instance will be deployed"
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

variable "freeform_tags" {
  description = "Free form tags"
  type        = any
}


variable "compartment_name" {
  description = "Compartment name"
  type        = string
}