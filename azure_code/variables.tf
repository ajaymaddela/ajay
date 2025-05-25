variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default = ""
}

variable "sku" {
  description = "SKU of the ACR (e.g., Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Enable admin user for ACR"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access to ACR"
  type        = bool
  default     = false
}

variable "encryption_enabled" {
  description = "Enable customer-managed key (CMK) encryption"
  type        = bool
  default     = false
}

variable "key_vault_key_id" {
  description = "Key Vault key ID for CMK encryption"
  type        = string
  default     = null
}

variable "network_rule_set" {
  description = "Optional network rules (ip_rules list and default_action)"
  type = object({
    default_action = string
    ip_rules = list(object({
      action   = string
      ip_range = string
    }))
  })
  default = null
}

variable "enable_private_endpoint" {
  description = "Create private endpoint for ACR"
  type        = bool
  default     = false
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for ACR"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "scope_map" {
  description = "Map of scope maps to create ACR tokens for. Each key is the scope name and value includes actions."
  type = map(object({
    actions = list(string)
  }))
  default = {} 
}

# redis
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

