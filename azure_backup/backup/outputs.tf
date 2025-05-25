output "recovery_vault_id" {
  description = "The ID of the Recovery Services Vault"
  value       = var.enable_vault ? azurerm_recovery_services_vault.vault[0].id : null
}

output "recovery_vault_name" {
  description = "The name of the Recovery Services Vault"
  value       = var.enable_vault ? azurerm_recovery_services_vault.vault[0].name : null
}

output "vm_backup_policy_id" {
  description = "The ID of the VM backup policy"
  value       = var.enable_vm_backup_policy ? azurerm_backup_policy_vm.vm[0].id : null
}

output "vm_backup_policy_name" {
  description = "The name of the VM backup policy"
  value       = var.enable_vm_backup_policy ? azurerm_backup_policy_vm.vm[0].name : null
}

output "file_backup_policy_id" {
  description = "The ID of the file share backup policy"
  value       = var.enable_file_backup_policy ? azurerm_backup_policy_file_share.file[0].id : null
}

output "file_backup_policy_name" {
  description = "The name of the file share backup policy"
  value       = var.enable_file_backup_policy ? azurerm_backup_policy_file_share.file[0].name : null
}

output "backup_protected_vms" {
  description = "Map of VM names to their backup resource IDs"
  value       = var.enable_protected_vms ? {
    for name, vm in azurerm_backup_protected_vm.protected_vm :
    name => vm.id
  } : {}
}

output "backup_protected_file_shares" {
  description = "Map of file share names to their backup resource IDs"
  value       = var.enable_protected_file_shares ? {
    for name, share in azurerm_backup_protected_file_share.protected_share :
    name => share.id
  } : {}
}

output "backup_container_id" {
  description = "The ID of the registered backup container"
  value       = var.enable_storage_container ? azurerm_backup_container_storage_account.container[0].id : null
}
