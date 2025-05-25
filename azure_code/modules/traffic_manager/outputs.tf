output "traffic_manager_id" {
  value = azurerm_traffic_manager_profile.tm.id
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}