module "traffic" {
  source = "./modules/traffic_manager"
  resource_group                = "python1234"
vnet_name                     = "test"
subnet_name                   = "public-subnet-0"

traffic_manager_name          = "traffic-manager"
traffic_routing_method        = "Performance"
relative_dns_name             = "ajaymaddela-online"
tm_ttl                        = 30
monitor_protocol              = "HTTP"
monitor_port                  = 80
monitor_path                  = "/"
use_external_endpoint         = true

use_azure_endpoint            = false
external_endpoint_name = "vm-endpoint"
external_endpoint_weight         = 100
external_endpoint_always_serve   = true


create_custom_domain_dns      = false
# dns_zone_name = "ajaymaddela.online"
# cname_record_name = "test"
# cname_record_ttl = 300
create_dns_a_record = false
# a_record_name = "testing"
# a_record_ttl = 300

}