# Azure Redis Cache Terraform Module

This Terraform module provisions an Azure Redis Cache instance with optional firewall rules, private endpoint, DNS integration, and diagnostics settings.

## Features

- Creates an Azure Redis Cache instance.
- Supports advanced Redis configuration.
- Optional firewall rule configuration.
- Private endpoint integration with private DNS support.
- Diagnostic settings to monitor Redis metrics and logs.

---

## Usage

```hcl
module "redis" {
  source = "./module/redis"

  name                       = "example-redis"
  resource_group             = "my-rg"
  location                   = "East US"

  capacity                   = 2
  redis_version              = 6
  family                     = "C"
  sku_name                   = "Standard"
  minimum_tls_version        = "1.2"
  enable_non_ssl_port        = false

  maxmemory_delta            = 200
  maxmemory_policy           = "allkeys-lru"
  maxmemory_reserved         = 100
  rdb_backup_enabled         = false

  vnet_name                  = "my-vnet"
  subnet_name                = "my-subnet"

  zones                      = ["1"]
  tags                       = {
    environment = "dev"
  }

  firewall_rules = [
    {
      name     = "AllowMyIP"
      start_ip = "203.0.113.1"
      end_ip   = "203.0.113.1"
    }
  ]

  enable_private_endpoint    = true
  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/my-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
}
```

---

## Inputs

| Name                          | Description                                              | Type      | Default | Required |
|-------------------------------|----------------------------------------------------------|-----------|---------|----------|
| `name`                        | Redis Cache name                                         | `string`  | n/a     | yes      |
| `resource_group`             | Resource group name                                      | `string`  | n/a     | yes      |
| `location`                   | Azure region                                             | `string`  | n/a     | yes      |
| `capacity`                   | Redis capacity                                           | `number`  | n/a     | yes      |
| `redis_version`              | Redis version                                            | `string`  | n/a     | yes      |
| `family`                     | Redis family                                             | `string`  | n/a     | yes      |
| `sku_name`                   | Redis SKU                                                | `string`  | n/a     | yes      |
| `minimum_tls_version`        | Minimum TLS version                                      | `string`  | "1.2"  | no       |
| `enable_non_ssl_port`        | Enable non-SSL port                                      | `bool`    | false   | no       |
| `maxmemory_delta`            | Memory delta for eviction                                | `number`  | 0       | no       |
| `maxmemory_policy`           | Eviction policy                                          | `string`  | n/a     | yes      |
| `maxmemory_reserved`         | Reserved memory                                          | `number`  | 0       | no       |
| `rdb_backup_enabled`         | Enable RDB backup                                        | `bool`    | false   | no       |
| `vnet_name`                  | Virtual network name                                     | `string`  | n/a     | yes      |
| `subnet_name`                | Subnet name                                              | `string`  | n/a     | yes      |
| `zones`                      | Availability zones                                       | `list`    | `[]`    | no       |
| `tags`                       | Tags for resources                                       | `map`     | `{}`    | no       |
| `firewall_rules`             | List of firewall rules                                   | `list`    | `[]`    | no       |
| `enable_private_endpoint`    | Enable private endpoint                                  | `bool`    | false   | no       |
| `enable_diagnostics`         | Enable diagnostic logs and metrics                       | `bool`    | false   | no       |
| `log_analytics_workspace_id` | ID of Log Analytics Workspace                            | `string`  | ""      | no       |

---

## Outputs

| Name        | Description                         |
|-------------|-------------------------------------|
| `redis_id`  | ID of the Redis Cache instance      |
| `redis_hostname` | DNS name of the Redis Cache         |
| `redis_primary_key` | Redis primary access key          |
| `redis_ssl_port` | Redis ssl port          |



