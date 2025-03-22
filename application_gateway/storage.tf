module "storage_monitoring" {
  source             = "./modules/storage_monitoring"
  resource_group     = module.networking.resource_group_name_output
  location          = module.networking.region_output
  storage_account_tier = var.storage_account_tier
  log_analytics = var.log_analytics
  log_sku = var.log_sku
  depends_on = [ module.networking ]
}
