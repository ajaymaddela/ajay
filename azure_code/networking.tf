module "network" {
  source = "./modules/networking"
  region = "West Europe"
  resource_group_name = "python1234"
  vnet_name = "test"
  vnet_cidr = "10.0.0.0/16"
  public_subnet_count = 2
  private_subnet_count = 2
}