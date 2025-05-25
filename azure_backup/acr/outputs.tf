output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = azurerm_container_registry.this.name
}

output "acr_login_server" {
  description = "The login server of the ACR"
  value       = azurerm_container_registry.this.login_server
}

output "acr_admin_username" {
  description = "Admin username for ACR (if enabled)"
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_username : null
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password for ACR (if enabled)"
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_password : null
  sensitive   = true
}

output "acr_id" {
  description = "Resource ID of the ACR"
  value       = azurerm_container_registry.this.id
}

output "acr_private_endpoint_ip" {
  description = "Private IP of ACR private endpoint (if enabled)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.acr_private_endpoint[0].private_service_connection[0].private_ip_address : null
}
