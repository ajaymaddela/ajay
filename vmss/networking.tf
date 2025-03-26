module "network" {
  source = "./modules/networking"
  region = "eastus"
  resource_group_name = "python122"
  vnet_name = "test"
  vnet_cidr = "10.0.0.0/16"
  public_subnet_count = 2
  private_subnet_count = 2
  log_analytics_workspace_name = "lesworkspace"
  log_sku = "PerGB2018"
}