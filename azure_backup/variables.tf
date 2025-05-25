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
  default = ""
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

# Traffic manager
variable "traffic_manager_name" {
  description = "Name of the Traffic Manager profile"
  type        = string
  default = ""
}

variable "traffic_routing_method" {
  description = "Traffic routing method (e.g., Performance, Priority, Weighted)"
  type        = string
  default = ""
}

variable "relative_dns_name" {
  description = "Relative DNS name for Traffic Manager"
  type        = string
  default = ""
}

variable "tm_ttl" {
  description = "TTL for the DNS configuration"
  type        = number
  default = 0
}

variable "monitor_protocol" {
  description = "Monitor protocol (HTTP, HTTPS, TCP)"
  type        = string
  default = ""
}

variable "monitor_port" {
  description = "Monitor port"
  type        = number
  default = 0
}

variable "monitor_path" {
  description = "Monitor path for health probe"
  type        = string
  default = ""
}

variable "use_external_endpoint" {
  description = "Whether to use an external endpoint"
  type        = bool
  default = false
}

variable "external_endpoint_name" {
  description = "Name of the external endpoint"
  type        = string
  default = ""
}

variable "external_endpoint_weight" {
  description = "Weight of the external endpoint"
  type        = number
  default = 0
}

variable "external_endpoint_always_serve" {
  description = "Whether the external endpoint should always serve traffic"
  type        = bool
  default = false
}

variable "external_endpoint_target" {
  description = "Target FQDN or public IP of the external endpoint"
  type        = string
  default = ""
}

variable "use_azure_endpoint" {
  description = "Whether to use an Azure endpoint"
  type        = bool
  default = false
}

variable "azure_endpoint_name" {
  description = "Name of the Azure endpoint"
  type        = string
  default = ""
}

variable "azure_endpoint_resource_id" {
  description = "Resource ID of the Azure endpoint target"
  type        = string
  default = ""
}

variable "azure_endpoint_weight" {
  description = "Weight of the Azure endpoint"
  type        = number
  default = 0
}

variable "azure_endpoint_priority" {
  description = "Priority of the Azure endpoint"
  type        = number
  default = 0
}

variable "azure_endpoint_enabled" {
  description = "Enable or disable the Azure endpoint"
  type        = bool
  default = false
}

variable "azure_endpoint_always_serve" {
  description = "Whether the Azure endpoint should always serve traffic"
  type        = bool
  default = false
}

variable "azure_endpoint_geo_mappings" {
  description = "Geo-mappings for Azure endpoint"
  type        = list(string)
  default     = []
}

variable "create_custom_domain_dns" {
  description = "Flag to create a custom DNS zone and CNAME"
  type        = bool
  default = false
}

variable "dns_zone_name" {
  description = "Name of the DNS zone"
  type        = string
  default = ""
}

variable "cname_record_name" {
  description = "Name of the CNAME record"
  type        = string
  default = ""
}

variable "cname_record_ttl" {
  description = "TTL for the CNAME record"
  type        = number
  default = null
}

variable "create_dns_a_record" {
  type = bool
  default = true
}

variable "a_record_name" {
  type = string
  default = "testing"
}

variable "a_record_ttl" {
  type = number
  default = 300
}

variable "dns_a_record" {
  type = list(string)
  default = null
}


# backup
variable "enable_vault" {
  type        = bool
  default     = true
  description = "Enable recovery services vault"
}

variable "recovery_vault_name" {
  type        = string
  default     = "example-recovery-vault"
}

variable "recovery_vault_sku" {
  type        = string
  default     = "Standard"
}

variable "recovery_vault_storage_mode_type" {
  type        = string
  default     = ""
}

variable "recovery_vault_cross_region_restore_enabled" {
  type        = bool
  default     = false
}

variable "recovery_vault_soft_delete_enabled" {
  type        = bool
  default     = true
}

variable "recovery_vault_identity_type" {
  type        = string
  default     = null
}

variable "identity_ids" {
  type        = list(string)
  default     = []
}

variable "recovery_vault_encryption_enabled" {
  type        = bool
  default     = false
}

variable "recovery_vault_encryption_key_vault_key_id" {
  type        = string
  default     = ""
}

variable "recovery_vault_encryption_use_system_assigned_identity" {
  type        = bool
  default     = false
}

variable "recovery_vault_infrastructure_encryption_enabled" {
  type        = bool
  default     = false
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
}

# VM Backup Policy Variables
variable "enable_vm_backup_policy" {
  type    = bool
  default = false
}

variable "vm_backup_policy_name" {
  type    = string
  default = "vm-backup-policy"
}

variable "vm_backup_timezone" {
  type    = string
  default = "UTC"
}

variable "vm_backup_frequency" {
  type    = string
  default = "Daily"
}

variable "vm_backup_time" {
  type    = string
  default = "23:00"
}

variable "vm_retention_daily_count" {
  type    = number
  default = 7
}

variable "vm_retention_monthly_count" {
  type    = number
  default = 6
}

variable "vm_retention_monthly_weekdays" {
  type    = list(string)
  default = ["Sunday"]
}

variable "vm_retention_monthly_weeks" {
  type    = list(string)
  default = ["First"]
}

# File Share Backup Policy Variables
variable "enable_file_backup_policy" {
  type    = bool
  default = false
}

variable "file_backup_policy_name" {
  type    = string
  default = "file-backup-policy"
}

variable "file_backup_timezone" {
  type    = string
  default = "UTC"
}

variable "file_backup_frequency" {
  type    = string
  default = "Daily"
}

variable "file_backup_time" {
  type    = string
  default = "23:00"
}

variable "file_retention_daily_count" {
  type    = number
  default = 7
}

variable "file_retention_weekly_count" {
  type    = number
  default = 4
}

variable "file_retention_weekdays" {
  type    = list(string)
  default = ["Sunday"]
}

# Storage Account Container Registration
variable "enable_storage_container" {
  type    = bool
  default = false
}

variable "storage_account_id" {
  type    = string
  default = ""
}

# Protected VMs
variable "enable_protected_vms" {
  type    = bool
  default = false
}

variable "protected_vms" {
  type = list(object({
    name   = string
    vm_id  = string
  }))
  default = []
}

# Protected File Shares
variable "enable_protected_file_shares" {
  type    = bool
  default = false
}

variable "protected_file_shares" {
  type = list(object({
    name               = string
    storage_account_id = string
    file_share_name    = string
  }))
  default = []
}