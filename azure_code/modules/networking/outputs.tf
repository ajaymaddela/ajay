output "resource_group_name_output" {
  value = azurerm_resource_group.rg.name
}

output "region_output" {
  value = azurerm_resource_group.rg.location
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "public_subnet_name" {
  value = azurerm_subnet.public[*].name
}
output "public_subnets" {
  value = azurerm_subnet.public[*].id
}

output "public_subnet_address_prefix" {
  value = flatten(azurerm_subnet.public[*].address_prefixes)
}

# output "workspace_id" {
#   value = azurerm_log_analytics_workspace.log_analytics.id

# }

# output "workspace_customer_id" {
#   value = azurerm_log_analytics_workspace.log_analytics.workspace_id
# }

# output "workspace_primary_shared_key" {
#   value = azurerm_log_analytics_workspace.log_analytics.primary_shared_key
# }