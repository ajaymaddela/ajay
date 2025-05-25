variable "resource_group" {
  description = "Resource Group name for Traffic Manager"
  type        = string
}

variable "vnet_name" {
  type = string
  default = ""
}

variable "subnet_name" {
  type = string
  default = ""
}