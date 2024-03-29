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
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public.id
  }
  depends_on = [azurerm_subnet.app]

}
resource "azurerm_public_ip" "public" {
  name                = "publickeytype"
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"

}
resource "azurerm_linux_virtual_machine" "qtdevops" {
  name                  = "qtdevops"
  location              = var.region
  resource_group_name   = var.resource_group_name
  admin_username        = "ubuntu"
  network_interface_ids = [azurerm_network_interface.qtlt.id]
  size                  = "Standard_D2s_v3"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  disable_password_authentication = true
  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")

  }
  depends_on = [azurerm_public_ip.public]
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"

  }
  provisioner "remote-exec" {
    inline = [ 
      "apt update",
      "apt install python3 -y",
      "apt install software-properties-common",
      "add-apt-repository --yes --update ppa:ansible/ansible",
      "apt install ansible unzip -y"
     ]
     connection {
      type = "ssh"
      user = "ubuntu"
      host = "localhost"
     }
  }
  provisioner "local-exec" {
    command = "ansible-playbook -i ${hosts} nopansible.yaml"
  
  }
}
resource "azurerm_sql_server" "anji" {
  name = "renuka"
  location = var.region
  resource_group_name = var.resource_group_name
  version = "12.0"
  administrator_login = "anjali"
  administrator_login_password = "Ajay@12345678"
  
}
resource "azurerm_storage_account" "qtgt" {
  name = "ltqtsample"
  resource_group_name = var.resource_group_name
  location = var.region
  account_tier = "Standard"
  account_replication_type = "LRS"
  
}
resource "azurerm_sql_database" "ajay" {
  name = "srinivas"
  resource_group_name = var.resource_group_name
  location = var.region
  server_name = azurerm_sql_server.anji.name
  tags = {
    "environment" = "development"
  }
  lifecycle {
    prevent_destroy = true
  }
}
output "public_ip_address" {
  value = azurerm_linux_virtual_machine.qtdevops.public_ip_address

}