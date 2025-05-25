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
      start_ip_address = "106.222.235.49"
      end_ip_address   = "106.222.235.49"
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