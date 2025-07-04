module "redis" {
  source              = "./modules/redis"
  redis_name                = var.redis_name
  resource_group      = module.network.resource_group_name_output
  vnet_name = module.network.vnet_name
  subnet_name = module.network.public_subnet_name[0]
  sku_name            = var.sku_name
  family              = var.family
  capacity            = var.capacity 
  redis_version = var.redis_version
  rdb_backup_enabled = var.rdb_backup_enabled
  maxmemory_delta = var.maxmemory_delta
  maxmemory_policy = var.maxmemory_policy
  maxmemory_reserved = var.maxmemory_reserved
  zones               = var.zones
  enable_non_ssl_port = var.enable_non_ssl_port
  minimum_tls_version = var.minimum_tls_version
  tags                = var.tags
  firewall_rules      = var.firewall_rules
  enable_private_endpoint       = var.enable_private_endpoint
  enable_diagnostics            = var.enable_diagnostics
}
