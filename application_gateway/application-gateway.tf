module "application_gateway" {
  source             = "./modules/application-gateway"
  resource_group     = module.networking.resource_group_name_output
  region          = module.networking.region_output
  app_gw_name      = var.app_gw_name
  public_subnet_id  = module.networking.public_subnets[0]
  storage_account_id = module.storage_monitoring.storage_account_id
  diagnostic_name = var.diagnostic_name
  keyvault_name = var.keyvault_name
  depends_on = [ module.networking ]
}