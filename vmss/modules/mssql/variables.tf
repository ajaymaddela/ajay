# General Configuration
variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "location_secondary" {
  description = "Secondary Azure region for failover"
  type        = string
}

# Networking
variable "vnet_name" {
  description = "Existing Virtual Network name"
  type        = string
}



variable "subnet_name" {
  description = "Existing Subnet name"
  type        = string
}

# SQL Configuration
variable "sql_server_primary" {
  description = "Primary SQL Server name"
  type        = string
}

variable "sql_server_version" {
  type = string
}

variable "sql_database_name" {
  description = "SQL Database name"
  type        = string
}

variable "sku_name" {
  description = "SQL Database SKU"
  type        = string
}

variable "collation" {
  description = "Database collation setting"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "max_size_gb" {
  description = "Maximum database size in GB"
  type        = number
  default     = 5
}

# Failover Configuration
variable "enable_failover" {
  type = bool
  default = false
}

variable "sql_server_secondary" {
  description = "Secondary SQL Server name"
  type        = string
  default = ""
}
variable "failover_group_name" {
  description = "Name of the failover group"
  type        = string
  default = ""
}

variable "failover_grace_minutes" {
  description = "Grace period before failover"
  type        = number
  default     = 80
}

# Security
variable "admin_username" {
  description = "SQL Server administrator username"
  type        = string
}

variable "admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
}

variable "database_zone_redundant" {
  type = bool
  default = false
}

variable "failover_mode" {
  type = string
  default = "Automatic"
}

variable "allowed_ips" {
  description = "Map of allowed IPs for firewall rules"
  type        = map(string)
  default = null
}

variable "enable_backup" {
  type = bool
  default = false
}
# Storage
variable "storage_account_name" {
  description = "Storage account name for backups"
  type        = string
}

variable "enable_auditing" {
  type = bool
  default = true
}

variable "audit_storage_account_name" {
  type = string
  default = "ajaydwjdn"
}

variable "retention_days" {
  type = number
  default = 6
}
variable "tags" {
  type = map(string)
}