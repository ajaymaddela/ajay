
variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "existing_subnet_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "nsg_name" {
 type = string
 default = ""
}

variable "mysql_server_name" {
  type = string
}

variable "mysql_server_version" {
  type = string
}

variable "mysql_server_size" {
  type = number
}

variable "backup_retention_days" {
  type = number
}

variable "mysql_zone" {
  type = string
}
variable "mysql_admin_user" {
  type = string
}

variable "mysql_admin_password" {
  type = string
  sensitive = true
}

variable "mysql_sku" {
  default = "B_Standard_B1s"
}

variable "mysql_db_name" {
  description = "MySQL database name"
  type = string
}

variable "dns_zone_vnet_link" {
  type = string
  default = ""
}

variable "allowed_ips" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = null
}

variable "private_dns_zone_name" {
  default = "privatelink.mysql.database.azure.com"
}

variable "mysql_db_charset" {
  type = string
}

variable "mysql_db_collation" {
  type = string
}
