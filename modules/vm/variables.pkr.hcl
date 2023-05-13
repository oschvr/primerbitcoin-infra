variable "image_name" {
  description = "Image name"
  type        = string
}

variable "instance_name" {
  description = "Instance name"
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
  description = "Tags for instances"
  type        = any
}

variable "ssh_username" {
  description = "SSH Username"
  type        = string
}

variable "subnet_ocid" {
  description = "OCID of Subnet to deploy instance to"
  type        = string
}

variable "availability_domain" {
  description = "OCI Availability Domain"
  type        = string
}