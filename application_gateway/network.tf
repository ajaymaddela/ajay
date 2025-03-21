provider "azurerm" {
  features {}
  subscription_id = "fc3acc55-41d9-4150-8f51-6588e3da9612"
}

module "networking" {
  source             = "./modules/networking"
  resource_group     = var.resource_group
  region = var.region
  vnet_name         = var.vnet_name
  vnet_cidr        = var.vnet_cidr
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
}

