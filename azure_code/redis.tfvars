redis_name = "tredisd"
sku_name            = "Premium"
family              = "P"
capacity            = 2
zones               = ["1"]
enable_non_ssl_port = false
minimum_tls_version = "1.2"
tags                = {
  env               = "prod"
  app               = "myapp"
}
firewall_rules      = [
  {     
    name            = "AllowDev"
    start_ip        = "192.168.1.1"
    end_ip          = "192.168.1.1"
  }
]
enable_private_endpoint       = true
enable_diagnostics            = false