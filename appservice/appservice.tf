module "app_service" {
  source = "./modules/app-service"
  resource_group    = module.networking.resource_group_name_output
  app_service_name       = var.app_service_name
  app_service_plan_name  = var.app_service_plan_name
  storage_account_name   = module.storage_monitoring.storage_account_name
  storage_container_name = var.storage_container_name
  os_type = var.os_type
  application_insights_enabled = var.application_insights_enabled
  application_insights_id      = var.application_insights_id
  app_insights_name            = var.app_insights_name
  application_insights_type    = var.application_insights_type
  retention_in_days            = var.retention_in_days
  disable_ip_masking           = var.disable_ip_masking
  enable_identity              = var.enable_identity

  # App Stack
  enable_application_stack = var.enable_application_stack
  application_stack = var.application_stack
  app_settings = var.app_settings
  default_documents = var.default_documents
  health_check_path = var.health_check_path
  http2_enabled     = var.http2_enabled
  enable_https      = var.enable_https
  ips_allowed       = var.ips_allowed
  scm_ips_allowed   = var.scm_ips_allowed
  enable_auth_settings            = var.enable_auth_settings
  default_auth_provider           = var.default_auth_provider
  unauthenticated_client_action   = var.unauthenticated_client_action
  token_store_enabled             = var.token_store_enabled
  enable_backup = var.enable_backup
  backup_settings = var.backup_settings
  per_site_scaling = var.per_site_scaling
  tags = var.tags
}
  