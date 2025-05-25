# Terraform Module: Azure Backup

## Overview

This Terraform module provisions a complete **Azure Backup** configuration, including a Recovery Services Vault, backup policies for both virtual machines and file shares, and protection of VMs and Azure Files. The module is highly configurable and supports optional resources through flags.

## Features

- Creates a Recovery Services Vault with optional identity and encryption.
- VM backup policy with daily and monthly retention.
- File share backup policy with daily and weekly retention.
- Registers Storage Account container for backup.
- Protects selected VMs and file shares based on policies.

## Usage

```hcl
module "azure_backup" {
  source = "./modules/azure-backup"
  
  enable_vault = true
  resource_group                     = "my-rg"
  recovery_vault_name               = "myRecoveryVault"
  recovery_vault_sku                = "Standard"
  recovery_vault_storage_mode_type = "GeoRedundant"
  recovery_vault_soft_delete_enabled = true

  
  # Optional: Identity
  recovery_vault_identity_type = "UserAssigned"
  identity_ids = ["/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myIdentity"]

  # Optional: Encryption
  recovery_vault_encryption_enabled = true
  recovery_vault_encryption_key_vault_key_id = "<key-id>"
  recovery_vault_encryption_use_system_assigned_identity = false
  recovery_vault_infrastructure_encryption_enabled = true

  enable_vm_backup_policy = true
  vm_backup_policy_name   = "vmPolicy"
  vm_backup_timezone      = "UTC"
  vm_backup_frequency     = "Daily"
  vm_backup_time          = "23:00"
  vm_retention_daily_count = 7
  vm_retention_monthly_count = 6
  vm_retention_monthly_weekdays = ["Sunday"]
  vm_retention_monthly_weeks    = ["First"]

  enable_file_backup_policy = true
  file_backup_policy_name   = "filePolicy"
  file_backup_timezone      = "UTC"
  file_backup_frequency     = "Daily"
  file_backup_time          = "22:00"
  file_retention_daily_count = 7
  file_retention_weekly_count = 4
  file_retention_weekdays     = ["Friday"]

  enable_storage_container = true
  storage_account_id       = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Storage/storageAccounts/mystorage"

  enable_protected_vms = true
  protected_vms = [
    {
      name  = "vm1"
      vm_id = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Compute/virtualMachines/vm1"
    }
  ]

  enable_protected_file_shares = true
  protected_file_shares = [
    {
      name                = "share1"
      storage_account_id  = "/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Storage/storageAccounts/mystorage"
      file_share_name     = "myshare"
    }
  ]

  extra_tags = {
    environment = "production"
  }
}
```

## Inputs

| Name                                             | Type           | Description                                                   |
|--------------------------------------------------|----------------|---------------------------------------------------------------|
| resource_group                                   | string         | Name of the resource group where the vault and policies reside |
| enable_vault                                     | bool           | Controls creation of vault                                    |
| recovery_vault_name                              | string         | Name of the Recovery Services Vault                           |
| recovery_vault_sku                               | string         | SKU for the vault (e.g. Standard)                             |
| recovery_vault_storage_mode_type                 | string         | Storage mode (e.g., GeoRedundant)                             |
| recovery_vault_soft_delete_enabled               | bool           | Enable soft delete                                            |
| recovery_vault_cross_region_restore_enabled      | bool           | Enable cross region restore (optional)                        |
| recovery_vault_identity_type                     | string (null)  | Identity type: SystemAssigned or UserAssigned (optional)      |
| identity_ids                                     | list(string)   | List of identity IDs (if user-assigned)                       |
| recovery_vault_encryption_enabled                | bool           | Enable encryption settings                                    |
| recovery_vault_encryption_key_vault_key_id       | string         | Key Vault key ID for encryption                               |
| recovery_vault_encryption_use_system_assigned_identity | bool    | Use system-assigned identity for encryption                   |
| recovery_vault_infrastructure_encryption_enabled | bool           | Enable infrastructure encryption                              |
| enable_vm_backup_policy                          | bool           | Enable VM backup policy creation                              |
| vm_backup_policy_name                            | string         | Name of the VM backup policy                                  |
| vm_backup_timezone                               | string         | Timezone for VM backups                                       |
| vm_backup_frequency                              | string         | Frequency (e.g., Daily)                                       |
| vm_backup_time                                   | string         | Backup time (e.g., "23:00")                                   |
| vm_retention_daily_count                         | number         | Daily retention count                                         |
| vm_retention_monthly_count                       | number         | Monthly retention count                                       |
| vm_retention_monthly_weekdays                    | list(string)   | Weekdays for monthly retention                                |
| vm_retention_monthly_weeks                       | list(string)   | Weeks for monthly retention                                   |
| enable_file_backup_policy                        | bool           | Enable file share backup policy                               |
| file_backup_policy_name                          | string         | File share policy name                                        |
| file_backup_timezone                             | string         | Timezone for file share backup                                |
| file_backup_frequency                            | string         | Frequency for file share backup                               |
| file_backup_time                                 | string         | Time for file share backup                                    |
| file_retention_daily_count                       | number         | Daily retention for file shares                               |
| file_retention_weekly_count                      | number         | Weekly retention count                                        |
| file_retention_weekdays                          | list(string)   | Weekdays for weekly retention                                 |
| enable_storage_container                         | bool           | Register Storage Account container for backup                 |
| storage_account_id                               | string         | ID of the Storage Account                                     |
| enable_protected_vms                             | bool           | Enable VM protection                                          |
| protected_vms                                    | list(object)   | List of VMs to be protected                                   |
| enable_protected_file_shares                     | bool           | Enable file share protection                                  |
| protected_file_shares                            | list(object)   | List of file shares to be protected                           |
| extra_tags                                       | map(string)    | Additional tags to apply                                      |

## Outputs

| Name                       | Description                             |
|----------------------------|-----------------------------------------|
| recovery_vault_id          | ID of the Recovery Services Vault       |
| recovery_vault_name          | Name of the Recovery Services Vault       |
| vm_backup_policy_id        | ID of the VM backup policy              |
| vm_backup_policy_name        | NAme of the VM backup policy              |
| file_backup_policy_id      | ID of the file share backup policy      |
| backup_protected_vms    | List of protected VM resource IDs       |
| backup_protected_file_shares  | List of protected file share resource IDs |
| backup_container_id  | The ID of the registered backup container |

## Notes

- Ensure that the required permissions are granted for the identity assigned to the Recovery Vault.
- The module supports full conditional logic to create only the needed components.
- Tags can help organize your backup resources effectively in cost analysis and resource tracking tools.