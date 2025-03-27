module "mssql" {
  source = "./modules/mssql"
  resource_group_name     = module.network.resource_group_name_output
location_secondary      = "North Europe"

vnet_name              = module.network.vnet_name

subnet_name           = module.network.public_subnet_name[0]
sql_server_primary    = "mssqlserver-primary"
sql_server_version = "12.0"
sql_database_name     = "exampledb"
max_size_gb           = 2
sku_name              = "S0"
admin_username        = "sqladmin"
admin_password        = "PA%%w0rd*"
allowed_ips = {
  "OfficeIP"   = "106.222.235.49"
  "HomeIP"     = "106.222.235.49"
  "VPNGateway" = "106.222.235.49"
}
storage_account_name  = "examplewestoragesql"
tags = {
  "key" = "ajay"
}
}