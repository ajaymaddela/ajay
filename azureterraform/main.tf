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
resource "azurerm_subnet" "subnets" {
  name                 = var.subnet_names[count.index]
  count                = length(var.subnet_names)
  virtual_network_name = azurerm_virtual_network.akki.name
  resource_group_name  = azurerm_resource_group.ajay.name
  address_prefixes     = [cidrsubnet(var.network_cidr, 8, count.index)]
  depends_on           = [azurerm_virtual_network.akki]

}
