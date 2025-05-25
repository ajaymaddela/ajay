# Fetch Existing Resource Group
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group
}

# Fetch Existing VNet and Subnet
data "azurerm_virtual_network" "existing_vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

data "azurerm_subnet" "existing_subnet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}

# Redis Cache
resource "azurerm_redis_cache" "this" {
  name                = var.redis_name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  capacity            = var.capacity
  redis_version       = var.redis_version
  family              = var.family
  sku_name            = var.sku_name
  minimum_tls_version = var.minimum_tls_version
  non_ssl_port_enabled = var.enable_non_ssl_port
  zones               = var.zones
  tags                = var.tags

  redis_configuration {
    maxmemory_delta    = var.maxmemory_delta
    maxmemory_policy   = var.maxmemory_policy
    maxmemory_reserved = var.maxmemory_reserved
    rdb_backup_enabled = var.rdb_backup_enabled
  }
}

# Firewall Rules
resource "azurerm_redis_firewall_rule" "this" {
  count               = length(var.firewall_rules)
  name                = var.firewall_rules[count.index].name
  redis_cache_name    = azurerm_redis_cache.this.name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  start_ip            = var.firewall_rules[count.index].start_ip
  end_ip              = var.firewall_rules[count.index].end_ip
}

# Private Endpoint
resource "azurerm_private_endpoint" "this" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.redis_name}-pe"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  subnet_id           = data.azurerm_subnet.existing_subnet.id

  private_service_connection {
    name                           = "${var.redis_name}-psc"
    private_connection_resource_id = azurerm_redis_cache.this.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [ azurerm_private_dns_zone.redis[0].id ]
  }
  tags = var.tags
  depends_on = [ azurerm_redis_cache.this ]
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "redis" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  tags                = var.tags
  depends_on = [ azurerm_redis_cache.this ]
}

# DNS Zone Virtual Network Link
resource "azurerm_private_dns_zone_virtual_network_link" "redis_vnet_link" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = "${var.redis_name}-dns-vnet-link"
  resource_group_name   = data.azurerm_resource_group.existing_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.redis[0].name
  virtual_network_id    = data.azurerm_virtual_network.existing_vnet.id
  registration_enabled  = false
  tags                  = var.tags
  depends_on = [ azurerm_redis_cache.this ]
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.enable_diagnostics ? 1 : 0
  name                       = "${var.redis_name}-diag"
  target_resource_id         = azurerm_redis_cache.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "RedisAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
  depends_on = [ azurerm_redis_cache.this ]
}
