# module "application_gateway" {
#   source             = "./modules/application-gateway"
#   resource_group     = module.networking.resource_group_name_output
#   location          = module.networking.region_output
# #   vnet_name         = module.networking.vnet_name
#   app_gw_name      = var.app_gw_name
#   public_subnet_id  = module.networking.public_subnets[0]
# #   ssl_cert_data = 
# #   ssl_cert_password = 
#   depends_on = [ module.networking ]
# }