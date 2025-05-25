variable "resource_group" {
  type        = string
  description = "Name of the existing resource group"
}

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
