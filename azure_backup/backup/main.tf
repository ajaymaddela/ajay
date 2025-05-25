data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group
}

resource "azurerm_recovery_services_vault" "vault" {
  count               = var.enable_vault ? 1 : 0
  name                = var.recovery_vault_name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  sku = var.recovery_vault_sku
  storage_mode_type            = var.recovery_vault_storage_mode_type
  cross_region_restore_enabled = var.recovery_vault_cross_region_restore_enabled
  soft_delete_enabled          = var.recovery_vault_soft_delete_enabled

  dynamic "identity" {
    for_each = var.recovery_vault_identity_type != null ? [1] : []
    content {
      type         = var.recovery_vault_identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "encryption" {
    for_each = var.recovery_vault_encryption_enabled ? [1] : []
    content {
      key_id                              = var.recovery_vault_encryption_key_vault_key_id
      use_system_assigned_identity        = var.recovery_vault_encryption_use_system_assigned_identity
      infrastructure_encryption_enabled   = var.recovery_vault_infrastructure_encryption_enabled
    }
  }

  tags = merge(var.extra_tags)
}

resource "azurerm_backup_policy_vm" "vm" {
  count               = var.enable_vm_backup_policy ? 1 : 0
  name                = var.vm_backup_policy_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault[0].name
  timezone            = var.vm_backup_timezone

  backup {
    frequency = var.vm_backup_frequency
    time      = var.vm_backup_time
  }

  retention_daily {
    count = var.vm_retention_daily_count
  }

  retention_monthly {
    count    = var.vm_retention_monthly_count
    weekdays = var.vm_retention_monthly_weekdays
    weeks    = var.vm_retention_monthly_weeks
  }
}

resource "azurerm_backup_policy_file_share" "file" {
  count               = var.enable_file_backup_policy ? 1 : 0
  name                = var.file_backup_policy_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault[0].name
  timezone            = var.file_backup_timezone

  backup {
    frequency = var.file_backup_frequency
    time      = var.file_backup_time
  }

  retention_daily {
    count = var.file_retention_daily_count
  }

  retention_weekly {
    count    = var.file_retention_weekly_count
    weekdays = var.file_retention_weekdays
  }
}

resource "azurerm_backup_container_storage_account" "container" {
  count               = var.enable_storage_container ? 1 : 0
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault[0].name
  storage_account_id  = var.storage_account_id
}

resource "azurerm_backup_protected_vm" "protected_vm" {
  for_each = var.enable_protected_vms ? { for vm in var.protected_vms : vm.name => vm } : {}

  resource_group_name = data.azurerm_resource_group.existing_rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault[0].name
  source_vm_id        = each.value.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.vm[0].id
}

resource "azurerm_backup_protected_file_share" "protected_share" {
  for_each = var.enable_protected_file_shares ? { for share in var.protected_file_shares : share.name => share } : {}

  source_storage_account_id = each.value.storage_account_id
  resource_group_name       = data.azurerm_resource_group.existing_rg.name
  recovery_vault_name       = azurerm_recovery_services_vault.vault[0].name
  source_file_share_name    = each.value.file_share_name
  backup_policy_id          = azurerm_backup_policy_file_share.file[0].id
}