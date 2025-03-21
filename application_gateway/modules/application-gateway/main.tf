# resource "azurerm_public_ip" "app_gw_pip" {
#   name                = "appgw-pip"
#   resource_group_name = var.resource_group
#   location            = var.region
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_application_gateway" "appgw" {
#   name                = var.app_gw_name
#   location            = var.region
#   resource_group_name = var.resource_group

#   sku {
#     name     = "Standard_v2"
#     tier     = "Standard_v2"
#     capacity = 2
#   }

#   autoscale_configuration {
#     min_capacity = 2
#     max_capacity = 5
#   }

#   gateway_ip_configuration {
#     name      = "appgw-ip-config"
#     subnet_id = var.public_subnet_id
#   }

#   frontend_ip_configuration {
#     name                          = "appgw-frontend-ip"
#     public_ip_address_id          = azurerm_public_ip.app_gw_pip.id
#   }

#   frontend_port {
#     name = "https-port"
#     port = 443
#   }

# #   ssl_certificate {
# #     name     = "ssl-cert"
# #     data     = var.ssl_cert_data
# #     password = var.ssl_cert_password
# #   }

#   http_listener {
#     name                           = "https-listener"
#     frontend_ip_configuration_name = "appgw-frontend-ip"
#     frontend_port_name             = "https-port"
#     protocol                       = "Https"
#     # ssl_certificate_name           = "ssl-cert"
#   }

#   backend_address_pool {
#     name = "backend-pool"
#   }

#   backend_http_settings {
#     name                  = "backend-http-settings"
#     cookie_based_affinity = "Disabled"
#     port                  = 443
#     path                  = "/"  
#     protocol              = "Https"
#     request_timeout       = 60
#   }

#   probe {
#     name                = "https-health-probe"
#     protocol            = "Https"
#     path                = "/health"
#     interval = 30
#     timeout  = 10
#     unhealthy_threshold = 3
#   }

#   request_routing_rule {
#     name                       = "https-rule"
#     priority = 9
#     rule_type                  = "Basic"
#     http_listener_name         = "https-listener"
#     backend_address_pool_name  = "backend-pool"
#     backend_http_settings_name = "backend-http-settings"
#   }

  

#   depends_on = [azurerm_public_ip.app_gw_pip]
# }
