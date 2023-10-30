variable "compartment_id" {
  description = "OCID of compartment where instance will be deployed"
  type        = string
}

variable "display_name" {
  description = "Display name of instance"
  type        = string
}

variable "subnet_id" {
  description = "OCID of subnet where instance will be deployed"
  type        = string
}

variable "image_id" {
  description = "OCID of ubuntu 22.04 minimal image for uk-london-1 region"
  type        = string
}

variable "shape" {
  # https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm
  # https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm
  # Available Shapes
  # Micro instances (AMD processor): All tenancies get up to two Always Free VM instances using the VM.Standard.E2.1.Micro shape, which has an AMD processor.
  # Ampere A1 Compute instances (Arm processor): All tenancies get the first 3,000 OCPU hours and 18,000 GB hours per month for free for VM instances using the VM.Standard.A1.Flex shape, which has an Arm processor. For Always Free tenancies, this is equivalent to 4 OCPUs and 24 GB of memory.

  description = "Shape of OCI Instance. The shape determines the number of CPUs and the amount of memory allocated to the instance. Using Always free shapes"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "freeform_tags" {
  description = "Free form tags"
  type        = any
}

variable "nsg_ids" {
  description = "List of NSG OCIDs to attach to instance"
  type        = list(string)
}

variable "reserved_ip" {
  type        = string
  default     = "RESERVED"
}