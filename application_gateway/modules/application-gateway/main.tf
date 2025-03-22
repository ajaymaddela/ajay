data "azurerm_client_config" "current" {
}

########################################
# Azure Key Vault (To Store Certificate)
########################################
resource "azurerm_key_vault" "keyvault" {
  name                        = var.keyvault_name
  location                    = var.region
  resource_group_name         = var.resource_group
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
}

########################################
# Store SSL Certificate in Key Vault
########################################
# resource "azurerm_key_vault_secret" "appgw_cert_secret" {
#   name         = "appgw-cert-secret"
#   value        = filebase64("${path.module}/appgw.pfx") # Upload PFX certificate
#   key_vault_id = azurerm_key_vault.keyvault.id
# }

resource "azurerm_public_ip" "app_gw_pip" {
  name                = "appgw-pip"
  resource_group_name = var.resource_group
  location            = var.region
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.app_gw_name
  location            = var.region
  resource_group_name = var.resource_group

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.public_subnet_id
  }

  frontend_ip_configuration {
    name                          = "appgw-frontend-ip"
    public_ip_address_id          = azurerm_public_ip.app_gw_pip.id
  }

frontend_port {
    name = "http-port"
    port = 80
  }

#   frontend_port {
#     name = "https-port"
#     port = 443
#   }

#   ssl_certificate {
#     name     = "ssl-cert"
#     key_vault_secret_id = azurerm_key_vault_secret.appgw_cert_secret.id
#   }

#   http_listener {
#     name                           = "https-listener"
#     frontend_ip_configuration_name = "appgw-frontend-ip"
#     frontend_port_name             = "https-port"
#     protocol                       = "Https"
#     # ssl_certificate_name           = "ssl-cert"
    
#   }

# backend_http_settings {
#     name                  = "backend-http-settings"
#     cookie_based_affinity = "Disabled"
#     port                  = 443
#     path                  = "/"  
#     protocol              = "Https"
#     request_timeout       = 60
#   }

   http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
    # ssl_certificate_name           = "ssl-cert"
    
  }
  backend_address_pool {
    name = "backend-pool"
    
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    path                  = "/"  
    protocol              = "Http"
    request_timeout       = 60
  }

  probe {
    name                = "http-health-probe"
    protocol            = "Http"
    path                = "/health"
    interval = 30
    timeout  = 10
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
  }

  request_routing_rule {
    name                       = "http-rule"
    priority = 9
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
  }

  depends_on = [azurerm_public_ip.app_gw_pip]
}


resource "azurerm_monitor_diagnostic_setting" "monitor" {
  name               = var.diagnostic_name
  target_resource_id = azurerm_application_gateway.appgw.id
  storage_account_id = var.storage_account_id

  # Corrected Log Categories
  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }

  #  Only include this if WAF is enabled
  # enabled_log {
  #   category = "ApplicationGatewayFirewallLog"
  # }

  metric {
    category = "AllMetrics"
  }
}
