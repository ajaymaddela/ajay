module "acr" {
  source = "./acr"
  resource_group                  = module.network.resource_group_name_output
  vnet_name                       = module.network.vnet_name
  subnet_name                     = module.network.public_subnet_name[0]
  acr_name                        = var.acr_name
  sku                             = var.sku
  admin_enabled                   = var.admin_enabled
  public_network_access_enabled   = var.public_network_access_enabled
  enable_private_endpoint         = var.enable_private_endpoint
  enable_diagnostics              = var.enable_diagnostics
  log_analytics_workspace_id      = var.log_analytics_workspace_id 
  encryption_enabled              = var.encryption_enabled
  key_vault_key_id                = var.key_vault_key_id
  network_rule_set                = var.network_rule_set
  scope_map                       = var.scope_map
  tags                            = var.tags
}