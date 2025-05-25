# Data sources for existing resources
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group
}

data "azurerm_virtual_network" "existing_vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

data "azurerm_subnet" "existing_subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

# Optional: User-assigned identity for CMK encryption
resource "azurerm_user_assigned_identity" "acr_identity" {
  count               = var.encryption_enabled ? 1 : 0
  name                = "${var.acr_name}-identity"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# ACR Resource
resource "azurerm_container_registry" "this" {
  name                          = var.acr_name
  location                      = data.azurerm_resource_group.existing_rg.location
  resource_group_name           = data.azurerm_resource_group.existing_rg.name
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  identity {
    type         = var.encryption_enabled ? "UserAssigned" : "SystemAssigned"
    identity_ids = var.encryption_enabled ? [azurerm_user_assigned_identity.acr_identity[0].id] : null
  }

  dynamic "encryption" {
    for_each = var.encryption_enabled ? [1] : []
    content {
      key_vault_key_id   = var.key_vault_key_id
      identity_client_id = azurerm_user_assigned_identity.acr_identity[0].client_id
    }
  }

  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [1] : []
    content {
      default_action = var.network_rule_set.default_action

      ip_rule = [
        for ip in var.network_rule_set.ip_rules : {
          action   = ip.action
          ip_range = ip.ip_range
        }
      ]
    }
  }
}

# Scope Map
resource "azurerm_container_registry_scope_map" "main" {
  for_each                = var.scope_map != null ? { for k, v in var.scope_map : k => v if v != null } : {}
  name                    = each.key
  resource_group_name     = data.azurerm_resource_group.existing_rg.name
  container_registry_name = azurerm_container_registry.this.name
  actions                 = each.value.actions
}

# ACR Token
resource "azurerm_container_registry_token" "main" {
  for_each                = var.scope_map != null ? { for k, v in var.scope_map : k => v if v != null } : {}
  name                    = "${each.key}-token"
  resource_group_name     = data.azurerm_resource_group.existing_rg.name
  container_registry_name = azurerm_container_registry.this.name
  scope_map_id            = azurerm_container_registry_scope_map.main[each.key].id
  enabled                 = true
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "acr" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.azurecr.io"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  depends_on          = [azurerm_container_registry.this]
}

# DNS Zone Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "acr_link" {
  count                     = var.enable_private_endpoint ? 1 : 0
  name                      = "${var.acr_name}-dns-link"
  resource_group_name       = data.azurerm_resource_group.existing_rg.name
  private_dns_zone_name     = azurerm_private_dns_zone.acr[0].name
  virtual_network_id        = data.azurerm_virtual_network.existing_vnet.id
  registration_enabled      = false
  depends_on                = [azurerm_container_registry.this]
}

# Private Endpoint
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.acr_name}-pe"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  subnet_id           = data.azurerm_subnet.existing_subnet.id

  private_service_connection {
    name                           = "${var.acr_name}-privatesc"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  tags       = var.tags
  depends_on = [azurerm_container_registry.this]
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "acr_diag" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.acr_name}-diag"
  target_resource_id         = azurerm_container_registry.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }

  depends_on = [azurerm_container_registry.this]
}
