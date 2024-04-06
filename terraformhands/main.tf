data "azurerm_resource_group" "ajay" {
  name = var.azurerm_resource_group


}
resource "azurerm_virtual_network" "anji" {
  name                = "ajay"
  resource_group_name = var.azurerm_resource_group
  location            = "eastus2"
  address_space       = ["192.168.0.0/16"]

}