  app_service_name       = "nodewebapp"
  app_service_plan_name  = "nodeappserviceplan"
  storage_container_name = "appser-container"
  os_type = "Linux"
  application_insights_enabled = true
  application_insights_id      = null
  app_insights_name            = "nodeappinsights"
  application_insights_type    = "web"
  retention_in_days            = 90
  disable_ip_masking           = false
  enable_identity              = true
  # Linux Node.js App Stack
  enable_application_stack = true
  application_stack = {
    node_version = "18-lts"
  }
  app_settings = {
    "WEBSITES_PORT"   = "3000"
    "WEBSITE_STACK"   = "node"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
  }
  default_documents = ["index.js"]
  health_check_path = "/health"
  http2_enabled     = true
  enable_https      = true
  ips_allowed       = ["0.0.0.0/0"]
  scm_ips_allowed   = ["0.0.0.0/0"]
  enable_auth_settings            = false
  default_auth_provider           = "AzureActiveDirectory"
  unauthenticated_client_action   = "RedirectToLoginPage"
  token_store_enabled             = true
  enable_backup = false
  backup_settings = null
  per_site_scaling = true
  tags = {
    Environment = "Development"
    Project     = "nodeapp"
  }