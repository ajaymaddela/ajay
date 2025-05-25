# Terraform Module: Azure MySQL Flexible Server with Private Networking

## Overview
This Terraform module provisions an **Azure MySQL Flexible Server** with **private networking**. It creates a delegated subnet, assigns a Network Security Group (NSG) with firewall rules, sets up Private DNS, and deploys the MySQL Flexible Server in an existing Azure Virtual Network (VNet).

## Features
- Deploys an **Azure MySQL Flexible Server** in an existing VNet.
- Creates a **delegated subnet** for MySQL.
- Configures a **Private DNS Zone** for internal name resolution.
- Enforces **NSG rules** to allow controlled access.
- Enables **firewall rules** for allowed IPs.
- Configures MySQL database settings and parameters.

## Usage
```hcl
module "mysql" {
  source = "./modules/mysql"
  # Azure Resource Group
  resource_group_name = "python1234"
  # Virtual Network & Subnet
  vnet_name   = "test"
  existing_subnet_name = "public-subnet-0"
  subnet_name = "mysql-subnet"
  # MySQL Flexible Server
  mysql_server_name   = "defaulttsql"
  mysql_server_version = "8.0.21"
  mysql_zone = "1"
  mysql_server_size = 20
  mysql_admin_user    = "adminuser"
  mysql_admin_password = "PA%%word*"  # Secure this value using environment variables or a vault
  mysql_db_name       = "test"
  mysql_db_charset = "utf8"
  mysql_db_collation = "utf8_unicode_ci"
  mysql_sku          = "GP_Standard_D2ds_v4"
  backup_retention_days = 7
  nsg_name = "testnsg"
  dns_zone_vnet_link = "mysql-dns-link"
  # Private DNS Zone
  private_dns_zone_name = "privatelink.mysql.database.azure.com"
  
  # Firewall Rule (VNet Access Only)
  allowed_ips = {
    "my_ip" = {
      start_ip_address = "106.222.235.49"
      end_ip_address   = "106.222.235.49"
    }
    "office_ip" = {
      start_ip_address = "192.168.1.1"
      end_ip_address   = "192.168.1.10"
    }
  }

}
```

## Variables
| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `resource_group_name` | Name of the existing Azure Resource Group | `string` | N/A |
| `vnet_name` | Name of the existing Virtual Network | `string` | N/A |
| `existing_subnet_name` | Name of an existing subnet | `string` | N/A |
| `subnet_name` | Name of the new subnet for MySQL | `string` | N/A |
| `nsg_name` | Name of the Network Security Group | `string` | N/A |
| `private_dns_zone_name` | Private DNS Zone for MySQL | `string` | `privatelink.mysql.database.azure.com` |
| `dns_zone_vnet_link` | Name of the DNS zone virtual network link | `string` | N/A |
| `mysql_server_name` | Name of the MySQL Flexible Server | `string` | N/A |
| `mysql_admin_user` | MySQL admin username | `string` | N/A |
| `mysql_admin_password` | MySQL admin password | `string` | N/A |
| `mysql_sku` | SKU for MySQL Server | `string` | `GP_Standard_D2ds_v4` |
| `mysql_server_version` | MySQL version | `string` | `8.0` |
| `mysql_zone` | Availability Zone for MySQL | `string` | `1` |
| `mysql_server_size` | Storage size in GB | `number` | `100` |
| `backup_retention_days` | Backup retention period in days | `number` | `7` |
| `mysql_db_name` | MySQL database name | `string` | `mydatabase` |
| `mysql_db_charset` | Database charset | `string` | `utf8mb4` |
| `mysql_db_collation` | Database collation | `string` | `utf8mb4_unicode_ci` |
| `allowed_ips` | List of allowed IP ranges | `map(object)` | `{}` |

## Outputs
| Output | Description |
|--------|-------------|
| `mysql_server_id` | The ID of the MySQL Flexible Server |
| `mysql_fqdn` | The fully qualified domain name of the MySQL server |
| `mysql_private_ip` | The private IP assigned to the MySQL server |

## Resources Created
This module provisions the following Azure resources:
1. **Azure MySQL Flexible Server**
2. **Delegated Subnet for MySQL**
3. **Network Security Group & Rules**
4. **Private DNS Zone for MySQL**
5. **VNet-to-DNS Zone Link**
6. **Firewall Rules for Allowed IPs**
7. **MySQL Database and Configuration**

## Notes
- The MySQL server is deployed with **private networking**, meaning it can only be accessed from the same VNet.
- **High Availability (HA)** can be enabled by modifying the `high_availability` block.
- Ensure that `mysql_admin_password` follows **Azure security policies**.
