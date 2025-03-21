module "storage_monitoring" {
  source             = "./modules/storage_monitoring"
  resource_group     = module.networking.resource_group_name_output
  location          = module.networking.region_output
}
