# Terraform Module: Azure Traffic Manager with DNS Integration

## Overview
This Terraform module creates and configures an **Azure Traffic Manager Profile** with support for both **Azure endpoints** and **external endpoints**, as well as optional DNS integration using **Azure DNS Zones**.

The module is designed to:
- Use an existing resource group, virtual network, and subnet.
- Create a Traffic Manager profile.
- Configure endpoints (Azure and/or external).
- Optionally create DNS zones, A records, and CNAME records.

---

## Resources Created
- `azurerm_traffic_manager_profile`
- `azurerm_traffic_manager_external_endpoint` *(optional)*
- `azurerm_traffic_manager_azure_endpoint` *(optional)*
- `azurerm_dns_zone` *(optional)*
- `azurerm_dns_cname_record` *(optional)*
- `azurerm_dns_a_record` *(optional)*

---

## Usage
```hcl
module "traffic_manager" {
  source = "./modules/traffic-manager"

  resource_group             = "my-rg"
  vnet_name                  = "my-vnet"
  subnet_name                = "my-subnet"
  traffic_manager_name       = "my-tm"
  traffic_routing_method     = "Priority"

  relative_dns_name          = "app-tm"
  tm_ttl                     = 30
  monitor_protocol           = "HTTP"
  monitor_port               = 80
  monitor_path               = "/"

  use_external_endpoint             = true
  external_endpoint_name            = "ext-endpoint"
  external_endpoint_weight          = 100
  external_endpoint_target          = "example.com"
  external_endpoint_always_serve   = true

  use_azure_endpoint                = true
  azure_endpoint_name              = "azure-endpoint"
  azure_endpoint_resource_id       = "/subscriptions/xxxx/resourceGroups/my-rg/providers/Microsoft.Network/publicIPAddresses/my-ip"
  azure_endpoint_weight            = 100
  azure_endpoint_priority          = 1
  azure_endpoint_enabled           = true
  azure_endpoint_always_serve      = false
  azure_endpoint_geo_mappings      = ["IN"]

  create_custom_domain_dns         = true
  dns_zone_name                    = "mydomain.com"
  cname_record_name                = "www"
  cname_record_ttl                 = 3600

  create_dns_a_record              = true
  a_record_name                    = "apiv2"
  a_record_ttl                     = 300
  dns_a_record                     = ["1.2.3.4"]
}
```

---

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `resource_group` | Name of existing resource group | `string` | n/a | yes |
| `vnet_name` | Name of existing virtual network | `string` | n/a | yes |
| `subnet_name` | Name of existing subnet | `string` | n/a | yes |
| `traffic_manager_name` | Name for Traffic Manager profile | `string` | n/a | yes |
| `traffic_routing_method` | Routing method (e.g., Priority, Performance) | `string` | n/a | yes |
| `relative_dns_name` | DNS name prefix for Traffic Manager | `string` | n/a | yes |
| `tm_ttl` | DNS TTL in seconds | `number` | `30` | no |
| `monitor_protocol` | Protocol for health check | `string` | `HTTP` | no |
| `monitor_port` | Port for health check | `number` | `80` | no |
| `monitor_path` | Path for health check | `string` | `/` | no |
| `use_external_endpoint` | Enable external endpoint | `bool` | `false` | no |
| `external_endpoint_name` | Name of external endpoint | `string` | n/a | no |
| `external_endpoint_weight` | Weight for external endpoint | `number` | `100` | no |
| `external_endpoint_target` | FQDN or public IP | `string` | n/a | no |
| `external_endpoint_always_serve` | Always serve from endpoint | `bool` | `false` | no |
| `use_azure_endpoint` | Enable Azure endpoint | `bool` | `false` | no |
| `azure_endpoint_name` | Name of Azure endpoint | `string` | n/a | no |
| `azure_endpoint_resource_id` | Resource ID of the Azure endpoint | `string` | n/a | no |
| `azure_endpoint_weight` | Weight of Azure endpoint | `number` | `100` | no |
| `azure_endpoint_priority` | Priority of Azure endpoint | `number` | `1` | no |
| `azure_endpoint_enabled` | Enable Azure endpoint | `bool` | `true` | no |
| `azure_endpoint_always_serve` | Always serve from endpoint | `bool` | `false` | no |
| `azure_endpoint_geo_mappings` | List of geo locations | `list(string)` | `[]` | no |
| `create_custom_domain_dns` | Create custom DNS zone and record | `bool` | `false` | no |
| `dns_zone_name` | Custom DNS zone name | `string` | n/a | no |
| `cname_record_name` | CNAME record name | `string` | n/a | no |
| `cname_record_ttl` | TTL for CNAME record | `number` | `3600` | no |
| `create_dns_a_record` | Create DNS A record | `bool` | `false` | no |
| `a_record_name` | A record name | `string` | n/a | no |
| `a_record_ttl` | TTL for A record | `number` | `300` | no |
| `dns_a_record` | A record IP address list | `list(string)` | `[]` | no |

---

## Outputs
| Name | Description |
|------|-------------|
| `traffic_manager_id` | ID of the Traffic Manager profile |


