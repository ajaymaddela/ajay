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

resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.existing_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "vm-public-ip"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "ubuntu-vm"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  disable_password_authentication = false
  admin_password = "Password1234!"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "disk"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
  provision_vm_agent = true
  custom_data = base64encode(<<-EOF
              #!/bin/bash
              apt update -y
              apt install apache2 -y
              systemctl start apache2
              systemctl enable apache2
            EOF
  )
}

resource "azurerm_traffic_manager_profile" "tm" {
  name                    = var.traffic_manager_name
  resource_group_name     = data.azurerm_resource_group.existing_rg.name
  traffic_routing_method  = var.traffic_routing_method
  dns_config {
    relative_name = var.relative_dns_name
    ttl           = var.tm_ttl
  }
  monitor_config {
    protocol = var.monitor_protocol
    port     = var.monitor_port
    path     = var.monitor_path
  }
}

# External Endpoint (for FQDN or public IP)
resource "azurerm_traffic_manager_external_endpoint" "external" {
  count                 = var.use_external_endpoint ? 1 : 0
  name                  = var.external_endpoint_name
  profile_id          = azurerm_traffic_manager_profile.tm.id
  weight = var.external_endpoint_weight
  always_serve_enabled = var.external_endpoint_always_serve
  target                = azurerm_public_ip.public_ip.ip_address
  endpoint_location     = data.azurerm_resource_group.existing_rg.location
  depends_on           = [azurerm_traffic_manager_profile.tm]
}

# Azure Endpoint (if using internal Azure VM/Resources)
resource "azurerm_traffic_manager_azure_endpoint" "azure" {
  count                        = var.use_azure_endpoint ? 1 : 0
  name                         = var.azure_endpoint_name
  profile_id                 = azurerm_traffic_manager_profile.tm.id
  target_resource_id           = azurerm_public_ip.public_ip.fqdn
  weight                       = var.azure_endpoint_weight
  priority                     = var.azure_endpoint_priority
  enabled = var.azure_endpoint_enabled
  always_serve_enabled = var.azure_endpoint_always_serve
  geo_mappings                 = var.azure_endpoint_geo_mappings
  depends_on = [ azurerm_traffic_manager_profile.tm ]
}

# Optional DNS Zone
resource "azurerm_dns_zone" "zone" {
  count               = var.create_custom_domain_dns ? 1 : 0
  name                = var.dns_zone_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# Optional CNAME Record pointing to Traffic Manager
resource "azurerm_dns_cname_record" "cname" {
  count               = var.create_custom_domain_dns ? 1 : 0
  name                = var.cname_record_name
  zone_name           = azurerm_dns_zone.zone[0].name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  ttl                 = var.cname_record_ttl
  record              = azurerm_traffic_manager_profile.tm.fqdn
}

resource "azurerm_dns_a_record" "example" {
  count               = var.create_dns_a_record ? 1 : 0
  name                = var.a_record_name
  zone_name           = azurerm_dns_zone.zone[0].name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  ttl                 = var.a_record_ttl
  records             = var.dns_a_record
}