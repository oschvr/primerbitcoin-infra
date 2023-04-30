variable "image_name" {
    description = "Image name"
    type = string
}

variable "instance_name" {
    description = "Instance name"
    type = string
}

var shape {
    description = "Shape (size, type) of the image"
    type = string
}