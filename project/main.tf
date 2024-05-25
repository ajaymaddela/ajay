module "appsoc_test" {
  source = "./terraform/vnet"

  resource_group_name = "apptesting"
  region              = "eastus"
  pub_subnet_names    = ["web-pub", "app-pub", "data-pub"]
  pvt_subnet_names    = ["web-pvt", "app-pvt", "data-pvt"]
  #pvt_subnet_cidrs            = ["10.20.0.0/24", "10.20.1.0/24", "10.20.2.0/24"]
  #pub_subnet_cidrs            = ["10.20.6.0/24", "10.20.7.0/24", "10.20.8.0/24"]
  network_cidr                = "10.20.0.0/16"
  virtual_network_name        = "appsocvnet"
  appsoc_nat                  = "appsocnat"
  sku_name                    = "Standard"
  idle_timeout_in_minutes     = 10
  zones_required              = ["1"]
  network_security_group      = "appsocnsg"
  network_security_group_rule = "appsocnsgrule"
  priority_number             = 300
  direction                   = "Inbound"
  access_rule                 = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_interface           = "appsocnetwork"
  ipconfig                    = "appsocnicip"
  route_table                 = "appsocroute"
  route_name                  = "appsocrot"
  address_prefix              = "10.20.6.0/24"
  next_hop_type               = "VirtualAppliance"
  next_hop_in_ip_address      = "10.0.0.1"
  public_ip_name              = "appsocpub"


  kubernetescluster_name = "appsoccluster"
  node_name              = "default"
  vm_size                = "Standard_D2_v2"
  node_count             = 2
  dns_prefix_name        = "appsocdnsprefix"
  identity               = "SystemAssigned"
  application_gateway    = "apssocapgt"

  sku_tier       = "Standard_v2"
  sku_capacity   = 2
  gatewayip_name = "appsocgateway"
  frontend_port  = 80
  cookie_based   = "Disabled"
  backend_port   = 80
  sku_apg        = "Standard_v2"
}