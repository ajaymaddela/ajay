variable "resource_group" {
  description = "Resource group name"
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
variable "redis_name" {
  description = "Redis cache name"
  type        = string
}

variable "sku_name" {
  description = "Redis SKU: Basic, Standard, or Premium"
  type        = string
  default     = "Standard"
}

variable "capacity" {
  description = "Size of Redis cache (0=250MB, 1=1GB, etc)"
  type        = number
  default     = 1
}

variable "family" {
  description = "SKU family: C for Basic/Standard, P for Premium"
  type        = string
  default     = "C"
}

variable "enable_non_ssl_port" {
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
}

variable "zones" {
  type    = list(string)
  default = []
}

variable "maxmemory_delta" {
  type = number
  default = 2
}

variable "maxmemory_reserved" {
  type = number
  default = 10
}

variable "maxmemory_policy" {
  type = string
  default = "volatile-lru"
}

variable "redis_version" {
  type = number
  default = 6
}

variable "rdb_backup_enabled" {
  type = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "firewall_rules" {
  description = "List of firewall rules"
  type = list(object({
    name     = string
    start_ip = string
    end_ip   = string
  }))
  default = []
}

# Private Endpoint
variable "enable_private_endpoint" {
  type    = bool
  default = false
}

# Diagnostics
variable "enable_diagnostics" {
  type    = bool
  default = false
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = ""
}
