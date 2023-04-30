variable "compartment_id" {
  description = "OCID of compartment where instance will be deployed"
  type        = string
}

variable "cidr_blocks" {
  description = "The list of one or more IPv4 CIDR blocks for the VCN"
  default     = ["172.16.0.0/16"]
  type        = list
}

variable "display_name" {
  description = "Display name of the VCN"
  type        = string
}