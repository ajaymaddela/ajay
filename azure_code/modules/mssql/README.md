# Terraform Module: Azure SQL Server with Failover and Private Endpoint

## Overview
This Terraform module deploys an Azure SQL Server setup with:
- Primary and optional secondary SQL Servers.
- SQL Database with failover support.
- Private Endpoint for secure access.
- Private DNS for name resolution.
- Dynamic firewall rules.
- Optional auditing to a storage account.

## Features
- **Primary SQL Server**: Deploys an Azure SQL Server with secure access controls.
- **SQL Database**: Creates a managed Azure SQL Database.
- **Failover Support**: Deploys a secondary SQL Server and a Failover Group if enabled.
- **Private Endpoint**: Ensures secure communication via Private Link.
- **Firewall Rules**: Allows access from specific IP ranges.
- **Auditing & Logging**: Stores logs in an Azure Storage Account.

## Usage
### Example Deployment
```hcl
module "mssql" {
  source = "./modules/mssql"
  resource_group_name     = "python1234" 
  vnet_name              = "test"
  subnet_name           = "public-subnet-0"
  sql_server_primary    = "mssqlserver-primary"
  sql_server_version = "12.0"
  sql_database_name     = "mssqltestdb"
  max_size_gb           = 2
  sku_name              = "S0"
  collation = "SQL_Latin1_General_CP1_CI_AS"
  admin_username        = "sqladmin"
  admin_password        = "PA%%w0rd*"
  allowed_ips = {
    "my_ip" = {
      start_ip_address = "106.232.165.79"
      end_ip_address   = "106.255.255.255"
    }
    "office_ip" = {
      start_ip_address = "192.168.1.1"
      end_ip_address   = "192.168.1.10"
    }
  }
  tags = {
    "key" = "test"
  }
}
```

## Inputs
| Name | Type | Description | Default |
|------|------|-------------|---------|
| `resource_group_name` | `string` | Name of the existing resource group | n/a |
| `vnet_name` | `string` | Name of the existing virtual network | n/a |
| `subnet_name` | `string` | Name of the existing subnet | n/a |
| `sql_server_primary` | `string` | Primary SQL Server name | n/a |
| `sql_server_secondary` | `string` | Secondary SQL Server name | n/a |
| `sql_database_name` | `string` | Name of the SQL database | n/a |
| `sql_server_version` | `string` | SQL Server version (e.g., 12.0) | `12.0` |
| `admin_username` | `string` | SQL Server administrator username | n/a |
| `admin_password` | `string` | SQL Server administrator password | n/a |
| `sku_name` | `string` | Database SKU | `Basic` |
| `collation` | `string` | Database collation | `SQL_Latin1_General_CP1_CI_AS` |
| `max_size_gb` | `number` | Maximum database size in GB | `10` |
| `database_zone_redundant` | `bool` | Enable zone redundancy for database | `false` |
| `enable_failover` | `bool` | Enable failover support | `false` |
| `location_secondary` | `string` | Location for secondary SQL Server | n/a |
| `failover_group_name` | `string` | Name of the failover group | n/a |
| `failover_mode` | `string` | Failover mode (`Automatic` or `Manual`) | `Automatic` |
| `failover_grace_minutes` | `number` | Grace period for failover (minutes) | `5` |
| `allowed_ips` | `map` | Map of IP ranges for firewall rules | `{}` |
| `enable_auditing` | `bool` | Enable auditing logs | `false` |
| `audit_storage_account_name` | `string` | Name of the storage account for auditing | n/a |
| `retention_days` | `number` | Retention period for logs (days) | `30` |
| `tags` | `map` | Tags for resources | `{}` |

## Outputs
| Name | Description |
|------|-------------|
| `primary_sql_server_id` | ID of the primary SQL Server |
| `secondary_sql_server_id` | ID of the secondary SQL Server (if enabled) |
| `sql_database_id` | ID of the created SQL Database |
| `failover_group_id` | ID of the failover group (if enabled) |
| `private_endpoint_id` | ID of the private endpoint |
| `audit_storage_id` | ID of the storage account for auditing (if enabled) |

## Notes
- **Failover is optional**: Set `enable_failover = true` to create a failover group.
- **Auditing is optional**: Logs are stored in a dedicated storage account.
- **Private Endpoint**: Ensures secure access to the database.
- **Firewall Rules**: Specify allowed IP ranges to access SQL Server.
