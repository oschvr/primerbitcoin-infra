variable "compartment_id" {
  description = "OCID of compartment where instance will be deployed"
  type        = string
}

variable "cidr_blocks" {
  description = "The list of one or more IPv4 CIDR blocks for the VCN"
  default     = ["172.16.0.0/16"]
  type        = list(any)
}

variable "display_name" {
  description = "Display name of the VCN"
  type        = string
}

variable "subnets" {
  description = "Private or Public subnets in a VCN"
  type        = any
  default     = {}
}

variable "freeform_tags" {
  description = "Free form tags"
  type        = any
}

variable "ssh_cidr" {
  description = "Trusted CIDR block to allow in NSG"
  type = string
}