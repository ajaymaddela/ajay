data "azurerm_client_config" "current" {
}

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
  name                 = var.existing_subnet_name
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
}


#Subnet for MySQL (Delegated)
resource "azurerm_subnet" "mysql_subnet" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
  virtual_network_name = data.azurerm_virtual_network.existing_vnet.name
  address_prefixes     = ["10.0.20.0/24"]
  private_link_service_network_policies_enabled = true
  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "mysql-flexible-delegation"

    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Network Security Group (NSG) for MySQL
resource "azurerm_network_security_group" "mysql_nsg" {
  name                = var.nsg_name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# Network security group rule for mysql
resource "azurerm_network_security_rule" "mysql_allow" {
  name                        = "mysql-allow"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.existing_rg.name
  network_security_group_name = azurerm_network_security_group.mysql_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "mysql_nsg_assoc" {
  subnet_id                 = azurerm_subnet.mysql_subnet.id
  network_security_group_id = azurerm_network_security_group.mysql_nsg.id
}

#Private DNS Zone for MySQL
resource "azurerm_private_dns_zone" "mysql_dns" {
  name                = var.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# Associate Private DNS Zone with VNet
resource "azurerm_private_dns_zone_virtual_network_link" "mysql_dns_link" {
  name                  = var.dns_zone_vnet_link
  resource_group_name   = data.azurerm_resource_group.existing_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.mysql_dns.name
  virtual_network_id    = data.azurerm_virtual_network.existing_vnet.id
}


# Firewall Rule: Allow required ips Only
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_private" {
  for_each = var.allowed_ips
  name                = each.key
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

#  MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = var.mysql_server_name
  location               = data.azurerm_resource_group.existing_rg.location
  resource_group_name    = data.azurerm_resource_group.existing_rg.name
  administrator_login    = var.mysql_admin_user
  administrator_password = var.mysql_admin_password
  sku_name               = var.mysql_sku
  version                = var.mysql_server_version
  zone                   = var.mysql_zone
  storage {
    size_gb = var.mysql_server_size
  }
  backup_retention_days  = var.backup_retention_days
  delegated_subnet_id    = azurerm_subnet.mysql_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.mysql_dns.id

  # high_availability {
  #   mode = "ZoneRedundant"  # Ensures HA across zones
  # }
  depends_on = [
    azurerm_private_dns_zone.mysql_dns,
    azurerm_private_dns_zone_virtual_network_link.mysql_dns_link  # <-- Critical addition
  ]

}

# MySQL Database
resource "azurerm_mysql_flexible_database" "db" {
  name                = var.mysql_db_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset            = var.mysql_db_charset
  collation          = var.mysql_db_collation
}

resource "azurerm_mysql_flexible_server_configuration" "example" {
  name                = "interactive_timeout"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "600"
}
