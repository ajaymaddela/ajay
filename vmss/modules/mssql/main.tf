# Fetch Existing Resource Group
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
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

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# SQL Primary Server
resource "azurerm_mssql_server" "primary" {
  name                         = "${var.sql_server_primary}-${random_string.suffix.result}"
  resource_group_name          = data.azurerm_resource_group.existing_rg.name
  location                     = data.azurerm_resource_group.existing_rg.location
  version                      = var.sql_server_version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  tags                         = merge(var.tags, { role = "primary" })
}

# Conditional SQL Secondary Server
resource "azurerm_mssql_server" "secondary" {
  count                        = var.enable_failover ? 1 : 0
  name                         = "${var.sql_server_secondary}-${random_string.suffix.result}"
  resource_group_name          = data.azurerm_resource_group.existing_rg.name
  location                     = var.location_secondary
  version                      = var.sql_server_version
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
  tags                         = merge(var.tags, { role = "secondary" })
}

# SQL Database
resource "azurerm_mssql_database" "main" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.primary.id
  sku_name       = var.sku_name
  collation      = var.collation
  max_size_gb    = var.max_size_gb
  zone_redundant = var.database_zone_redundant
  tags           = merge(var.tags, { environment = "production" })
}

# Failover Group
resource "azurerm_mssql_failover_group" "main" {
  count     = var.enable_failover ? 1 : 0
  name      = var.failover_group_name
  server_id = azurerm_mssql_server.primary.id
  databases = [azurerm_mssql_database.main.id]

  partner_server {
    id = azurerm_mssql_server.secondary[0].id
  }

  read_write_endpoint_failover_policy {
    mode          = var.failover_mode
    grace_minutes = var.failover_grace_minutes
  }

  tags = merge(var.tags, { component = "failover-group" })
}

# Private Endpoint for Azure SQL
resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "sql-private-endpoint"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  subnet_id           = data.azurerm_subnet.existing_subnet.id

  private_service_connection {
    name                           = "sql-private-connection"
    private_connection_resource_id = azurerm_mssql_server.primary.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

# Private DNS Zone for SQL Server
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# Link Private DNS to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "sql-dns-link"
  resource_group_name   = data.azurerm_resource_group.existing_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = data.azurerm_virtual_network.existing_vnet.id
}

# Dynamic Firewall Rules
resource "azurerm_mssql_firewall_rule" "allow_ips" {
  for_each = var.allowed_ips

  name                = each.key
  server_id           = azurerm_mssql_server.primary.id
  start_ip_address    = each.value
  end_ip_address      = each.value
}

# Conditional Storage Account for Backups
resource "azurerm_storage_account" "storage" {
  count                    = var.enable_backup ? 1 : 0
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.existing_rg.name
  location                 = data.azurerm_resource_group.existing_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "backups" {
  count                 = var.enable_backup ? 1 : 0
  name                  = "sql-backups"
  storage_account_id    = azurerm_storage_account.storage[0].id
  container_access_type = "private"
}


# Conditional Auditing
resource "azurerm_storage_account" "audit" {
  count                    = var.enable_auditing ? 1 : 0
  name                     = "${var.audit_storage_account_name}${random_string.suffix.result}"
  resource_group_name      = data.azurerm_resource_group.existing_rg.name
  location                 = data.azurerm_resource_group.existing_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = merge(var.tags, { purpose = "auditing" })
}

resource "azurerm_mssql_server_extended_auditing_policy" "main" {
  count                                   = var.enable_auditing ? 1 : 0
  server_id                               = azurerm_mssql_server.primary.id
  storage_endpoint                        = azurerm_storage_account.audit[0].primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.audit[0].primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.retention_days
}