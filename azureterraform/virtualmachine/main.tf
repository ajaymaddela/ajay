resource "azurerm_resource_group" "ajay" {
  name     = var.resource_group_name
  location = var.region

}
resource "azurerm_virtual_network" "akki" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.ajay.name
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  depends_on          = [azurerm_resource_group.ajay]
}
resource "azurerm_subnet" "app" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [var.subnet_cidr]
  depends_on           = [azurerm_virtual_network.akki]

}
resource "azurerm_network_interface" "qtlt" {
  name                = "quality"
  location            = var.region
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "thought"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Static"
  }
  depends_on = [azurerm_subnet.app]

}
resource "azurerm_public_ip" "publi" {
  name                = "publickeytype"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"

}
resource "azurerm_linux_virtual_machine" "qtdevops" {
  name                  = "qtdevops"
  location              = var.region
  resource_group_name   = var.resource_group_name
  admin_username        = "ubuntu"
  network_interface_ids = [azurerm_network_interface.qtlt.id]
  size                  = "Standard_B1s"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  disable_password_authentication = true
  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  depends_on = [azurerm_network_interface.qtlt]
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"


  }
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.qtdevops.public_ip_address

}