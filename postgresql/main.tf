resource "azurerm_resource_group" "example" {
  name     = "example-resour"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-netw"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
  depends_on = [ azurerm_resource_group.example ]
}

resource "azurerm_subnet" "example" {
  name                 = "internalnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
   service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
  depends_on = [ azurerm_virtual_network.example ]
}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
  depends_on = [ azurerm_resource_group.example ]
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "example-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
  depends_on = [ azurerm_resource_group.example ]
}

resource "azurerm_postgresql_server" "example" {
  name                = "example-ser"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  version             = "11"

  administrator_login          = "ajay"
  administrator_login_password = "P@ssw0rd123!"

  sku_name                = "GP_Gen5_2"
  storage_mb              = 32768
  ssl_enforcement_enabled = true
  depends_on = [ azurerm_resource_group.example ]
}


resource "azurerm_private_endpoint" "example" {
  name                = "example-endpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.example.id
#   id            = azurerm_postgresql_server.example.id
  

  private_dns_zone_group {
    name                 = "example-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.example.id]
  }

  private_service_connection {
    name                           = "example-connection"
    private_connection_resource_id = azurerm_postgresql_server.example.id
    is_manual_connection           = false
  }
  
  depends_on = [ azurerm_postgresql_server.example ]
}
# resource "azurerm_postgresql_server" "example" {
#   name                = "postgresql-serve"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name

#   sku_name = "GP_Gen5_2"

#   storage_mb                   = 5120
#   backup_retention_days        = 7
#   geo_redundant_backup_enabled = false
#   auto_grow_enabled            = true

#   administrator_login          = "psqladmin"
#   administrator_login_password = "H@Sh1CoR3!"
#   version                      = "11"
#   ssl_enforcement_enabled      = true
# }

resource "azurerm_postgresql_database" "example" {
  name                = "exampledb1"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
  depends_on = [ azurerm_resource_group.example ]
}