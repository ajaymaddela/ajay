module "backup" {
  source = "./backup"

  resource_group                              = module.network.resource_group_name_output
  enable_vault                                = var.enable_vault
  recovery_vault_name                         = var.recovery_vault_name
  recovery_vault_sku                          = var.recovery_vault_sku
  recovery_vault_storage_mode_type            = var.recovery_vault_storage_mode_type
  recovery_vault_cross_region_restore_enabled = var.recovery_vault_cross_region_restore_enabled
  recovery_vault_soft_delete_enabled          = var.recovery_vault_soft_delete_enabled
  recovery_vault_identity_type                = var.recovery_vault_identity_type
  identity_ids                                = var.identity_ids
  recovery_vault_encryption_enabled           = var.recovery_vault_encryption_enabled
  recovery_vault_encryption_key_vault_key_id  = var.recovery_vault_encryption_key_vault_key_id
  recovery_vault_encryption_use_system_assigned_identity = var.recovery_vault_encryption_use_system_assigned_identity
  recovery_vault_infrastructure_encryption_enabled = var.recovery_vault_infrastructure_encryption_enabled
  extra_tags = var.extra_tags
  enable_vm_backup_policy     = var.enable_vm_backup_policy
  vm_backup_policy_name       = var.vm_backup_policy_name
  vm_backup_timezone          = var.vm_backup_timezone
  vm_backup_frequency         = var.vm_backup_frequency
  vm_backup_time              = var.vm_backup_time
  vm_retention_daily_count    = var.vm_retention_daily_count
  vm_retention_monthly_count = var.vm_retention_monthly_count
  vm_retention_monthly_weekdays = var.vm_retention_monthly_weekdays
  vm_retention_monthly_weeks = var.vm_retention_monthly_weeks

  enable_file_backup_policy   = var.enable_file_backup_policy
  file_backup_policy_name     = var.file_backup_policy_name
  file_backup_timezone        = var.file_backup_timezone
  file_backup_frequency       = var.file_backup_frequency
  file_backup_time            = var.file_backup_time
  file_retention_daily_count  = var.file_retention_daily_count
  file_retention_weekly_count = var.file_retention_weekly_count
  file_retention_weekdays     = var.file_retention_weekdays

  enable_storage_container = var.enable_storage_container
  storage_account_id       = var.storage_account_id

  enable_protected_vms = var.enable_protected_vms
  # protected_vms = var.protected_vms
  protected_vms = [
    {
      name  = "vm-backup-01"
      vm_id = module.vm_traffic.vm_id
    }
  ]

  enable_protected_file_shares = var.enable_protected_file_shares
  protected_file_shares = var.protected_file_shares
}
