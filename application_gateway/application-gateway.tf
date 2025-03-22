module "application_gateway" {
  source             = "./modules/application-gateway"
  resource_group     = module.networking.resource_group_name_output
  region          = module.networking.region_output
  app_gw_name      = var.app_gw_name
  public_subnet_id  = module.networking.public_subnets[0]
  storage_account_id = module.storage_monitoring.storage_account_id
  diagnostic_name = var.diagnostic_name
  backend_address_pools = var.backend_address_pools
  backend_http_settings = var.backend_http_settings
  http_listeners = var.http_listeners
  sku = var.sku
  log_analytics_workspace_name = var.log_analytics_workspace_name
  log_sku = var.log_sku
  request_routing_rules = var.request_routing_rules
  identity_ids = [module.networking.identity_ids]
  depends_on = [ module.networking ]
}