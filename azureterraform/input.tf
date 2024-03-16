variable "resource_group_name" {
  type    = string
  default = "akki"
}


variable "region" {
  type        = string
  default     = "East US"
  description = "in which area region is located"

}
variable "subnet_names" {
  type    = list(string)
  default = ["web", "app", "data"]

}
variable "network_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "virtual_network_name" {
  type    = string
  default = "pradeep"

}