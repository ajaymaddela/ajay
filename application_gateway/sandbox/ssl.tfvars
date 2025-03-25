 
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
  # SKU requires `name`, `tier` to use for this Application Gateway
  # `Capacity` property is optional if `autoscale_configuration` is set
  sku = {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration = {
    min_capacity = 1
    max_capacity = 15
  }

  backend_address_pools = [
    {
      name  = "appgw-testgateway-bapool01"
      fqdns = ["example1.com", "example2.com"]
    },
    {
      name         = "appgw-testgateway-bapool02"
      ip_addresses = ["1.2.3.4", "2.3.4.5"]
    }
  ]

  backend_http_settings = [
    {
      name                  = "appgw-testgateway-be-http-set1"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      enable_https          = true
      request_timeout       = 30
      # probe_name            = "appgw-testgateway-probe1" # Remove this if `health_probes` object is not defined.
      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300

      }
    },
    {
      name                  = "appgw-testgateway-be-http-set2"
      cookie_based_affinity = "Enabled"
      path                  = "/"
      enable_https          = false
      request_timeout       = 30
    }
  ]

  http_listeners = [
    {
      name                 = "appgw-testgateway-be-htln01"
      ssl_certificate_name = "appgw-testgateway-ssl01"
      host_name            = null
    }
  ]
  request_routing_rules = [
    {
      name                       = "appgw-testgateway-be-rqrt"
      rule_type                  = "Basic"
      http_listener_name         = "appgw-testgateway-be-htln01"
      backend_address_pool_name  = "appgw-testgateway-bapool01"
      backend_http_settings_name = "appgw-testgateway-be-http-set1"
    }
  ]

  # TLS termination (previously known as Secure Sockets Layer (SSL) Offloading)
  # The certificate on the listener requires the entire certificate chain (PFX certificate) to be uploaded to establish the chain of trust.
  # Authentication and trusted root certificate setup are not required for trusted Azure services such as Azure App Service.
  ssl_certificates = [{
    name     = "appgw-testgateway-ssl01"
    data     = "./keyBag.pfx"
    password = "P@$$w0rd123"
  }]

  # By default, an application gateway monitors the health of all resources in its backend pool and automatically removes unhealthy ones. 
  # It then monitors unhealthy instances and adds them back to the healthy backend pool when they become available and respond to health probes.
  # must allow incoming Internet traffic on TCP ports 65503-65534 for the Application Gateway v1 SKU, and TCP ports 65200-65535 
  # for the v2 SKU with the destination subnet as Any and source as GatewayManager service tag. This port range is required for Azure infrastructure communication.
  # Additionally, outbound Internet connectivity can't be blocked, and inbound traffic coming from the AzureLoadBalancer tag must be allowed.
  health_probes = [
    {
      name                = "appgw-testgateway-probe1"
      host                = "127.0.0.1"
      interval            = 30
      path                = "/"
      port                = 443
      timeout             = 30
      unhealthy_threshold = 3
    }
  ]

