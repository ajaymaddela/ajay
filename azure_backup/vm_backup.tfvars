enable_vault = true
recovery_vault_name = "vetsdslt"
recovery_vault_sku = "Standard"
recovery_vault_storage_mode_type = "GeoRedundant"
recovery_vault_cross_region_restore_enabled = true
recovery_vault_soft_delete_enabled = true
recovery_vault_identity_type = null
identity_ids = null
recovery_vault_encryption_enabled = false
recovery_vault_encryption_key_vault_key_id = null
recovery_vault_encryption_use_system_assigned_identity = false
recovery_vault_infrastructure_encryption_enabled = false
extra_tags = {
  environment = "prod"
  owner       = "infra-team"
}

# VM Backup policy
enable_vm_backup_policy = true
vm_backup_policy_name = "daily-vm-policy"
vm_backup_timezone = "UTC"
vm_backup_frequency = "Daily"
vm_backup_time = "23:00"
vm_retention_daily_count = 7
vm_retention_monthly_count = 6
vm_retention_monthly_weekdays = ["Sunday"]
vm_retention_monthly_weeks = ["First"]

# No file backup or storage container
enable_file_backup_policy = false
enable_storage_container = false

# Enable and configure protected VMs
enable_protected_vms = true
enable_protected_file_shares = false
