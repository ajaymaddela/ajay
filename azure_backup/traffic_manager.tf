module "traffic" {
  source = "./traffic_manager"
  resource_group      = module.network.resource_group_name_output
  vnet_name = module.network.vnet_name
  subnet_name = module.network.public_subnet_name[0]
  
  traffic_manager_name          = var.traffic_manager_name
  traffic_routing_method        = var.traffic_routing_method
  relative_dns_name             = var.relative_dns_name
  tm_ttl                        = var.tm_ttl
  monitor_protocol              = var.monitor_protocol
  monitor_port                  = var.monitor_port
  monitor_path                  = var.monitor_path
  use_external_endpoint         = var.use_external_endpoint
  external_endpoint_name        = var.external_endpoint_name
  external_endpoint_weight         = var.external_endpoint_weight
  external_endpoint_always_serve   = var.external_endpoint_always_serve
  external_endpoint_target = module.vm_traffic.public_ip  # referring another module as external endpoint target
  use_azure_endpoint            = var.use_azure_endpoint
  azure_endpoint_always_serve = var.azure_endpoint_always_serve
  azure_endpoint_enabled = var.azure_endpoint_enabled
  azure_endpoint_geo_mappings = var.azure_endpoint_geo_mappings
  azure_endpoint_name = var.azure_endpoint_name
  azure_endpoint_priority = var.azure_endpoint_priority
  azure_endpoint_resource_id = var.azure_endpoint_resource_id
  azure_endpoint_weight = var.azure_endpoint_weight
  create_custom_domain_dns      = var.create_custom_domain_dns
  dns_zone_name = var.dns_zone_name
  cname_record_name = var.cname_record_name
  cname_record_ttl = var.cname_record_ttl
  create_dns_a_record = var.create_dns_a_record
  a_record_name = var.a_record_name
  a_record_ttl = var.a_record_ttl
  dns_a_record = var.dns_a_record
}