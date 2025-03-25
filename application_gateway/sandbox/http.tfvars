resource_group     = "python123"
region = "eastus"
vnet_name         = "test"
vnet_cidr        = "10.0.0.0/16"
public_subnet_count  = 2
private_subnet_count = 2
app_gw_name = "test"
diagnostic_name = "newonediag"
log_analytics_workspace_name = "log-workspace"
log_sku = "PerGB2018"
storage_account_tier = "Standard"
nsg_name = "nsgforsubnet"
user_identity = "testing"

# application gateway
sku = {
  name     = "Standard_v2"
  tier     = "Standard_v2"
  capacity = 2
}

health_probes = [
  {
    name                                      = "health-probe-1"
    host                                      = null
    interval                                  = 30
    path                                      = "/health"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    port                                      = 80
    pick_host_name_from_backend_http_settings = true
    minimum_servers                           = 1
    match = {
      body        = null
      status_code = ["200", "202"]
    }
  }
]

backend_address_pools = [
  {
    name  = "appgw-testgateway-bpol"
    fqdns = ["example1.com", "example2.com"]
  },
  {
    name         = "appgw-testgateway-bpo2"
    ip_addresses = ["10.0.3.4", "10.0.3.5"]
  }
]

  backend_http_settings = [
    {
      name                  = "appgw-testgateway-back-set"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      enable_https          = false
      request_timeout       = 30
      probe_name            = "health-probe-1"
      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300

      }
    },
    {
      name                  = "appgw-testgateway-westeurope-be-http-set2"
      cookie_based_affinity = "Enabled"
      path                  = "/"
      enable_https          = false
      request_timeout       = 30
    }
  ]



http_listeners = [
  {
    name      = "appgw-test-http-listener"
    host_name = null
  }
]

request_routing_rules = [
  {
    name                       = "appgw-test-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-test-http-listener"
    backend_address_pool_name  = "appgw-testgateway-bpo2"
    backend_http_settings_name = "appgw-testgateway-back-set"
    priority                   = 9
  }
]