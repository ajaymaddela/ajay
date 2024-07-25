terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.112.0"
    }
  }
}

provider "azurerm" {
  features {
    
  }
}
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vn"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-sn"
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
}
resource "azurerm_private_dns_zone" "example" {
  name                = "example.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "exampleVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
  resource_group_name   = azurerm_resource_group.example.name
  depends_on            = [azurerm_subnet.example]
}

resource "azurerm_postgresql_flexible_server" "example" {
  name                          = "example-psqlflexiblesver"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  version                       = "15"
  delegated_subnet_id           = azurerm_subnet.example.id
  private_dns_zone_id           = azurerm_private_dns_zone.example.id
  public_network_access_enabled = false
  administrator_login           = "psqladmin"
  administrator_password        = "H@Sh1CoR3!"
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P30"

  sku_name   = "GP_Standard_D4s_v3"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]

}

resource "azurerm_postgresql_flexible_server" "exampe" {
  name                          = "example-psqlflexilesver"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = azurerm_resource_group.example.location
  version                       = "15"
  delegated_subnet_id           = azurerm_subnet.example.id
  private_dns_zone_id           = azurerm_private_dns_zone.example.id
  public_network_access_enabled = false
  administrator_login           = "psqladmin"
  administrator_password        = "H@Sh1CoR3!"
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P30"
  create_mode = "Replica"
  source_server_id = azurerm_postgresql_flexible_server.example.id

  sku_name   = "GP_Standard_D4s_v3"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.example]

}
resource "azurerm_postgresql_flexible_server_database" "example" {
  name      = "exampledb"
  server_id = azurerm_postgresql_flexible_server.example.id
  collation = "en_US.utf8"
  charset   = "utf8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "example" {
  name             = "example-fw"
  server_id        = azurerm_postgresql_flexible_server.example.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Log in to Azure CLI
    #   az login

    #   # Set your subscription
    #   az account set --subscription "Your Subscription Name"