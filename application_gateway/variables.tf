
variable "resource_group" {
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

variable "app_gw_name" {
  type = string
}

variable "diagnostic_name" {
  type = string
}

variable "log_analytics" {
  type = string
}

variable "log_sku" {
  type = string
}

variable "storage_account_tier" {
  type = string
}

variable "keyvault_name" {
  type = string
}

variable "nsg_name" {
  type = string
}