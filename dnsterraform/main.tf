module "dns" {
  source = "./module"

  vpc_cidr               = var.vpc_cidr
  private_subnet_cidr    = var.private_subnet_cidr
  availability_zone      = var.availability_zone
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  domain_name            = var.domain_name
  domain_name_servers_ip = var.domain_name_servers_ip
  ip_for_transit         = var.ip_for_transit

}