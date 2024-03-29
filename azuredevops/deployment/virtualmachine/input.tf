variable "resource_group_name" {
  type    = string
  default = "akki"
}


variable "region" {
  type        = string
  default     = "East US"
  description = "in which area region is located"

}
variable "virtual_network_name" {
  type    = string
  default = "anji"

}
variable "subnet_name" {
  type    = string
  default = "web"

}
variable "network_cidr" {
  type    = string
  default = "192.168.0.0/16"

}
variable "network_interface" {
  type    = string
  default = "ltqt"

}
variable "machinename" {
  type    = string
  default = "qtdevops"

}
variable "subnet_cidr" {
  type    = string
  default = "192.168.0.0./24"

}