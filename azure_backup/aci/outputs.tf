output "aci_name" {
  description = "Name of the deployed container instance"
  value       = azurerm_container_group.aci.name
}

output "aci_fqdn" {
  description = "FQDN of the container instance (if public IP)"
  value       = azurerm_container_group.aci.fqdn
}

output "aci_ip_address" {
  description = "IP address assigned to the container instance"
  value       = azurerm_container_group.aci.ip_address
}

output "network_profile_id" {
  description = "Network profile ID (if created)"
  value       = try(azurerm_network_profile.net_prof[0].id, null)
}
