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