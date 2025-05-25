module "vm_traffic" {
  source = "./traffic_vm_example"
  resource_group      = module.network.resource_group_name_output
  vnet_name = module.network.vnet_name
  subnet_name = module.network.public_subnet_name[0]
}