resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.region

}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "public" {
  count                = var.public_subnet_count
  name                 = "public-subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${count.index}.0/24"]
}

resource "azurerm_subnet" "private" {
  count                = var.private_subnet_count
  name                 = "private-subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${count.index + 2}.0/24"]
}

########################################
# Network Security Group
########################################
resource "azurerm_network_security_group" "main" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  #  Required for App Gateway V2 (Ephemeral Ports)
  security_rule {
    name                       = "AllowAppGatewayInbound"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["65200-65535"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow outbound for App Gateway health checks
  security_rule {
    name                       = "AllowAppGatewayOutbound"
    priority                   = 1004
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["65200-65535"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


########################################
# Associate NSG to Subnet
########################################
resource "azurerm_subnet_network_security_group_association" "main" {
  for_each = { for idx, subnet in azurerm_subnet.public : idx => subnet }
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.main.id
}