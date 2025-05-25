variable "resource_group_name" {
  type = string
}

variable "region" {
  type = string
}
variable "vnet_name" {
  type = string
}
variable "vnet_cidr" {
  type = string
}
variable "public_subnet_count" {
  type = number
}

variable "private_subnet_count" {
  type = number
}