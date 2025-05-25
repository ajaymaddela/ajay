module "backup" {
  source = "./modules/backup" # or use Git URL if storing remotely

  resource_group                              = module.network.resource_group_name_output
  enable_vault                                = true
  recovery_vault_name                         = "my-recovery-vault"
  recovery_vault_sku                          = "Standard"
  recovery_vault_storage_mode_type            = "LocallyRedundant"
  recovery_vault_cross_region_restore_enabled = false
  recovery_vault_soft_delete_enabled          = true
  recovery_vault_identity_type                = null
  identity_ids                                = []
  recovery_vault_encryption_enabled           = false
  recovery_vault_encryption_key_vault_key_id  = null
  recovery_vault_encryption_use_system_assigned_identity = false
  recovery_vault_infrastructure_encryption_enabled = false

  extra_tags = {
    environment = "dev"
    owner       = "team"
  }

  enable_vm_backup_policy     = true
  vm_backup_policy_name       = "vm-backup-policy"
  vm_backup_timezone          = "UTC"
  vm_backup_frequency         = "Daily"
  vm_backup_time              = "23:00"
  vm_retention_daily_count    = 7
  vm_retention_monthly_count = 6
  vm_retention_monthly_weekdays = ["Sunday"]
  vm_retention_monthly_weeks = ["First"]

  enable_file_backup_policy   = false
#   file_backup_policy_name     = "file-backup-policy"
#   file_backup_timezone        = "UTC"
#   file_backup_frequency       = "Daily"
#   file_backup_time            = "23:00"
#   file_retention_daily_count  = 7
#   file_retention_weekly_count = 4
#   file_retention_weekdays     = ["Sunday"]

  enable_storage_container = false
#   storage_account_id       = "/subscriptions/xxx/resourceGroups/your-rg/providers/Microsoft.Storage/storageAccounts/yourstorage"

  enable_protected_vms = true
  protected_vms = [
    {
      name  = "vm1"
      vm_id = module.traffic.vm_id
    }
  ]

  enable_protected_file_shares = false
#   protected_file_shares = [
#     {
#       name               = "fileshare1"
#       storage_account_id = "/subscriptions/xxx/resourceGroups/your-rg/providers/Microsoft.Storage/storageAccounts/yourstorage"
#       file_share_name    = "yourfileshare"
#     }
#   ]
}
