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
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration = {
    min_capacity = 1
    max_capacity = 15
  }

  health_probes = [
  {
    name                                      = "health-probe-1"
    host                                      = null
    interval                                  = 30
    path                                      = "/health"
    timeout                                   = 30
    unhealthy_threshold                       = 3
    port                                      = 443
    pick_host_name_from_backend_http_settings = true
    minimum_servers                           = 1
    match = {
      body        = null
      status_code = ["200", "202"]
    }
  }
]


  # A backend pool routes request to backend servers, which serve the request.
  # Can create different backend pools for different types of requests
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

  # An application gateway routes traffic to the backend servers using the port, protocol, and other settings
  # The port and protocol used to check traffic is encrypted between the application gateway and backend servers
  # List of backend HTTP settings can be added here.  
  # `probe_name` argument is required if you are defing health probes.
  backend_http_settings = [
    {
      name                  = "appgw-testgateway-be-http-set1"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      enable_https          = true
      request_timeout       = 30
      # probe_name            = "appgw-testgateway-westeurope-probe1" # Remove this if `health_probes` object is not defined.
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

  # List of HTTP/HTTPS listeners. SSL Certificate name is required
  # `Basic` - This type of listener listens to a single domain site, where it has a single DNS mapping to the IP address of the 
  # application gateway. This listener configuration is required when you host a single site behind an application gateway.
  # `Multi-site` - This listener configuration is required when you want to configure routing based on host name or domain name for 
  # more than one web application on the same application gateway. Each website can be directed to its own backend pool.
  # Setting `host_name` value changes Listener Type to 'Multi site`. `host_names` allows special wildcard charcters.
  http_listeners = [
    {
      name                 = "appgw-testgateway-be-htln01"
      ssl_certificate_name = "appgw-testgateway-ssl01"
      host_name            = null
    }
  ]

  # Request routing rule is to determine how to route traffic on the listener. 
  # The rule binds the listener, the back-end server pool, and the backend HTTP settings.
  # `Basic` - All requests on the associated listener (for example, blog.contoso.com/*) are forwarded to the associated 
  # backend pool by using the associated HTTP setting.
  # `Path-based` - This routing rule lets you route the requests on the associated listener to a specific backend pool, 
  # based on the URL in the request. 
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

  # WAF configuration, disabled rule groups and exclusions.depends_on
  # The Application Gateway WAF comes pre-configured with CRS 3.0 by default. But you can choose to use CRS 3.2, 3.1, or 2.2.9 instead.
  # CRS 3.2 is only available on the `WAF_v2` SKU.
  waf_configuration = {
    firewall_mode            = "Detection"
    rule_set_version         = "3.1"
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128

    disabled_rule_group = [
      {
        rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
        rules           = ["930100", "930110"]
      },
      {
        rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
        rules           = ["920160"]
      }
    ]

    exclusion = [
      {
        match_variable          = "RequestCookieNames"
        selector                = "SomeCookie"
        selector_match_operator = "Equals"
      },
      {
        match_variable          = "RequestHeaderNames"
        selector                = "referer"
        selector_match_operator = "Equals"
      }
    ]
  }


  # Adding TAG's to Azure resources
  tags = {
    ProjectName  = "demo-internal"
    Env          = "dev"
    Owner        = "user@example.com"
    BusinessUnit = "CORP"
    ServiceClass = "Gold"
  }
