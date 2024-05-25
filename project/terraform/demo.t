resource "azurerm_resource_group" "appsoc_rg" {
  name     = var.resource_group_name
  location = var.region

}
resource "azurerm_virtual_network" "appsoc_vnet" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  address_space       = ["10.20.0.0/16"]
  location            = var.region
  depends_on          = [azurerm_resource_group.appsoc_rg]
}
resource "azurerm_subnet" "pub_subnets" {
  name                 = var.pub_subnet_names[count.index]
  count                = length(var.pub_subnet_names)
  virtual_network_name = azurerm_virtual_network.appsoc_vnet.name
  resource_group_name  = azurerm_resource_group.appsoc_rg.name
  address_prefixes     = [cidrsubnet(var.network_cidr, 8, count.index)]
  depends_on           = [azurerm_virtual_network.appsoc_vnet]

}
resource "azurerm_subnet" "pvt_subnet" {
  name                 = var.pvt_subnet_names[count.index]
  count                = length(var.pvt_subnet_names)
  virtual_network_name = azurerm_virtual_network.appsoc_vnet.name
  resource_group_name  = azurerm_resource_group.appsoc_rg.name
  address_prefixes     = [cidrsubnet(var.network_cidr, 8, count.index + 3)]
  depends_on           = [azurerm_virtual_network.appsoc_vnet]

}
resource "azurerm_public_ip" "public" {
  count               = length(var.pub_subnet_names)
  name                = "${var.pub_subnet_names[count.index]}-ip"
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  location            = var.region
  allocation_method   = "Dynamic"
  depends_on          = [azurerm_resource_group.appsoc_rg]

}
# resource "azurerm_subnet" "apgsubnet" {

#   name = "Applicationgateway"

#   virtual_network_name = azurerm_virtual_network.appsoc_vnet.name
#   resource_group_name  = azurerm_resource_group.appsoc_rg.name
#   address_prefixes     = ["10.20.20.0/24"]
#   depends_on           = [azurerm_virtual_network.appsoc_vnet]
# }
# resource "azurerm_public_ip" "publicforapg" {

#   name                = "publicip"
#   resource_group_name = azurerm_resource_group.appsoc_rg.name
#   location            = var.region
#   sku                 = "Standard"
#   allocation_method   = "Static"
#   depends_on          = [azurerm_resource_group.appsoc_rg]
# }
resource "azurerm_network_security_group" "appsoc_nsg" {
  name                = var.network_security_group
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  location            = var.region
  depends_on          = [azurerm_subnet.pub_subnets]
}
resource "azurerm_network_interface" "pvtappsoc_nic" {
  count               = length(var.pvt_subnet_names)
  name                = "${var.network_interface}-${var.pvt_subnet_names[count.index]}"
  location            = var.region
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  ip_configuration {
    name                          = var.ipconfig
    subnet_id                     = azurerm_subnet.pvt_subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = null
  }
  depends_on = [azurerm_subnet.pvt_subnet]
}

resource "azurerm_network_interface" "pubappsoc_nic" {
  count               = length(var.pub_subnet_names)
  name                = "${var.network_interface}-${var.pub_subnet_names[count.index]}"
  location            = var.region
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  ip_configuration {
    name                          = var.ipconfig
    subnet_id                     = azurerm_subnet.pub_subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public[count.index].id
  }
  depends_on = [azurerm_subnet.pub_subnets]
}

resource "azurerm_network_security_rule" "appsoc_nsg_rule1" {
  name                        = var.network_security_group_rule
  priority                    = var.priority_number
  direction                   = var.direction
  access                      = var.access_rule
  protocol                    = var.protocol
  source_port_range           = var.source_port_range
  destination_port_range      = var.destination_port_range
  source_address_prefix       = var.source_address_prefix
  destination_address_prefix  = var.destination_address_prefix
  resource_group_name         = azurerm_resource_group.appsoc_rg.name
  network_security_group_name = azurerm_network_security_group.appsoc_nsg.name
  depends_on                  = [azurerm_network_security_group.appsoc_nsg]

}
resource "azurerm_network_security_rule" "appsoc_nsg_rule2" {
  name                        = "appsocnsgrulesforpvt"
  priority                    = 320
  direction                   = "Inbound" #todo convert this into variables
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "10.20.0.0/16"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.appsoc_rg.name
  network_security_group_name = azurerm_network_security_group.appsoc_nsg.name
  depends_on                  = [azurerm_network_security_group.appsoc_nsg]

}
resource "azurerm_subnet_network_security_group_association" "appsocsec" {
  count                     = length(var.pub_subnet_names)
  subnet_id                 = azurerm_subnet.pub_subnets[count.index].id
  network_security_group_id = azurerm_network_security_group.appsoc_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "appsocsecurity" {
  count                     = length(var.pvt_subnet_names)
  subnet_id                 = azurerm_subnet.pvt_subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.appsoc_nsg.id
}

resource "azurerm_public_ip" "appsocipnat" {
  name                = "appsocnatip"
  location            = azurerm_resource_group.appsoc_rg.location
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}
resource "azurerm_nat_gateway_public_ip_association" "appsocassocipnat" {
  nat_gateway_id       = azurerm_nat_gateway.appsoc_nat.id
  public_ip_address_id = azurerm_public_ip.appsocipnat.id
}
resource "azurerm_nat_gateway" "appsoc_nat" {
  name                    = var.appsoc_nat
  location                = var.region
  resource_group_name     = azurerm_resource_group.appsoc_rg.name
  sku_name                = var.sku_name
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  zones                   = var.zones_required
  depends_on              = [azurerm_subnet.pub_subnets]

}


resource "azurerm_subnet_nat_gateway_association" "appsocnatassoc" {

  count = length(var.pvt_subnet_names)

  subnet_id      = azurerm_subnet.pvt_subnet[count.index].id
  nat_gateway_id = azurerm_nat_gateway.appsoc_nat.id
}
resource "azurerm_route_table" "appsoc_route" {
  name                = var.route_table
  location            = var.region
  resource_group_name = azurerm_resource_group.appsoc_rg.name

  route {
    name                   = var.route_name
    address_prefix         = var.address_prefix
    next_hop_type          = var.next_hop_type
    next_hop_in_ip_address = var.next_hop_in_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "appsocro" {
  count          = length(var.pvt_subnet_names)
  subnet_id      = azurerm_subnet.pvt_subnet[count.index].id
  route_table_id = azurerm_route_table.appsoc_route.id
}
resource "azurerm_kubernetes_cluster" "appsoc_clust" {
  name                = var.kubernetescluster_name
  location            = var.region
  resource_group_name = azurerm_resource_group.appsoc_rg.name

  default_node_pool {
    name       = var.node_name
    vm_size    = var.vm_size
    node_count = var.node_count
    # vnet_subnet_id =
  }

  dns_prefix = var.dns_prefix_name

  ingress_application_gateway {

    gateway_name = var.application_gateway
    subnet_cidr  = "10.225.0.0/16"
  }

  identity {
    type = var.identity
  }

  depends_on = [azurerm_resource_group.appsoc_rg]
}





locals {
  backend_address_pool_name      = "${azurerm_virtual_network.appsoc_vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.appsoc_vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.appsoc_vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.appsoc_vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.appsoc_vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.appsoc_vnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.appsoc_vnet.name}-rdrcfg"
}
# resource "azurerm_application_gateway" "appsoc_apg" {
#   name                = var.application_gateway
#   resource_group_name = azurerm_resource_group.appsoc_rg.name
#   location            = var.region
#   sku {
#     name     = var.sku_apg
#     tier     = var.sku_tier
#     capacity = var.sku_capacity
#   }
#   gateway_ip_configuration {
#     name      = var.gatewayip_name
#     subnet_id = azurerm_subnet.apgsubnet.id

#   }
#   frontend_port {
#     name = local.frontend_port_name
#     port = var.frontend_port
#   }
#   frontend_ip_configuration {
#     name                 = local.frontend_ip_configuration_name
#     public_ip_address_id = azurerm_public_ip.publicforapg.id

#   }
#   backend_address_pool {
#     name = local.backend_address_pool_name
#   }
#   backend_http_settings {
#     name                  = local.http_setting_name
#     cookie_based_affinity = var.cookie_based
#     port                  = var.backend_port
#     protocol              = "Http"
#     request_timeout       = 60
#   }
#   http_listener {
#     name                           = local.listener_name
#     frontend_ip_configuration_name = local.frontend_ip_configuration_name
#     frontend_port_name             = local.frontend_port_name
#     protocol                       = "Http"
#   }
#   request_routing_rule {
#     name                       = local.request_routing_rule_name
#     priority                   = 8
#     rule_type                  = "Basic"
#     http_listener_name         = local.listener_name
#     backend_address_pool_name  = local.backend_address_pool_name
#     backend_http_settings_name = local.http_setting_name
#   }
# }

data "azurerm_kubernetes_cluster" "default" {
  # refresh cluster state before reading
  name                = azurerm_kubernetes_cluster.appsoc_clust.name
  resource_group_name = azurerm_resource_group.appsoc_rg.name

}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
  #config_path            = "~/.kube/config"
}


resource "azurerm_storage_account" "appsoc_storage" {
  name                     = "appsocstorage"
  resource_group_name      = azurerm_resource_group.appsoc_rg.name
  location                 = azurerm_resource_group.appsoc_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "file" {
  name                 = "appsocfileshares"
  storage_account_name = azurerm_storage_account.appsoc_storage.name
  quota                = 50
  access_tier          = "Hot"



}
resource "azurerm_postgresql_server" "appsocpostgresserver" {
  name                = "appsocpostgresql-server-2"
  location            = azurerm_resource_group.appsoc_rg.location
  resource_group_name = azurerm_resource_group.appsoc_rg.name

  sku_name = "GP_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "appsocsqladmin"
  administrator_login_password = "appsoc@db123"
  version                      = "11"
  ssl_enforcement_enabled      = true
}

resource "azurerm_postgresql_database" "appsocpostgresqldatabase" {
  name                = "appsocdb"
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  server_name         = azurerm_postgresql_server.appsocpostgresserver.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}


resource "azurerm_postgresql_virtual_network_rule" "example" {
  name                                 = "appsocpostgresql-vnet-rule"
  resource_group_name                  = azurerm_resource_group.appsoc_rg.name
  server_name                          = azurerm_postgresql_server.appsocpostgresserver.name
  subnet_id                            = azurerm_subnet.pvt_subnet[1].id
  ignore_missing_vnet_service_endpoint = true
}


provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  region                   = "us-east-1"
}

data "aws_ecr_authorization_token" "example" {}

resource "kubernetes_secret" "docker-registry" {
  metadata {
    name = "docker-registry"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "730335556195.dkr.ecr.us-east-1.amazonaws.com" = {
          username = "AWS"
          password = base64encode(data.aws_ecr_authorization_token.example.password)
          email    = "your-email@example.com"
          auth     = base64encode("AWS:${data.aws_ecr_authorization_token.example.password}")
        }
      }
    })
  }

  depends_on = [
    azurerm_kubernetes_cluster.appsoc_clust,
  ]
}



resource "kubernetes_secret" "appsocsercet" {
  metadata {
    name = "appsoc-storage-account-key"
  }

  data = {
    azurestorageaccountname = azurerm_storage_account.appsoc_storage.name
    azurestorageaccountkey  = azurerm_storage_account.appsoc_storage.primary_access_key
  }
}



resource "kubernetes_storage_class" "appsocstorageclass" {
  metadata {
    name = "appsocstorageclass"
  }

  storage_provisioner = "file.csi.azure.com"

  reclaim_policy         = "Retain"
  allow_volume_expansion = true

  mount_options = [
    "dir_mode=0777",
    "file_mode=0777",
    "uid=0",
    "gid=0",
    "mfsymlinks",
    "cache=strict",
    "actimeo=30",
  ]

  parameters = {
    skuName = "Premium_LRS"
  }
}




resource "kubernetes_persistent_volume_claim" "appsoc-pvc" {
  metadata {
    name = "appsoc-pvc"
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "appsocstorageclass"

  }
}


resource "kubernetes_pod" "appsocpod" {
  metadata {
    name = "appsocpod"
  }

  spec {
    container {
      image = "730335556195.dkr.ecr.us-east-1.amazonaws.com/ajaykumar-008:latest"
      name  = "appsoccontainer"

      volume_mount {
        name       = "appsoc-pvc"
        mount_path = "/mnt/azure"
      }
    }

    volume {
      name = "appsoc-pvc"

      persistent_volume_claim {
        claim_name = kubernetes_persistent_volume_claim.appsoc-pvc.metadata.0.name
      }
    }
  }
}



#public ip for bastion host
resource "azurerm_public_ip" "publicforbastion" {

  name                = "bastionip"
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  location            = var.region
  sku                 = "Standard"
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.appsoc_rg]
}
resource "azurerm_subnet" "appsocsubnet" {

  name = "AzureBastionSubnet"

  virtual_network_name = azurerm_virtual_network.appsoc_vnet.name
  resource_group_name  = azurerm_resource_group.appsoc_rg.name
  address_prefixes     = ["10.20.20.0/24"]
  depends_on           = [azurerm_virtual_network.appsoc_vnet]
}
resource "azurerm_bastion_host" "example" {
  name                = "appsoc-bastion"
  location            = azurerm_resource_group.appsoc_rg.location
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  sku                 = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.appsocsubnet.id
    public_ip_address_id = azurerm_public_ip.publicforbastion.id
  }
}


resource "azurerm_private_endpoint" "appsocendpoint" {
  name                = "private-endpoint-sql"
  location            = azurerm_resource_group.appsoc_rg.location
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  subnet_id           = azurerm_subnet.pub_subnets[1].id

  private_service_connection {
    name                           = "private-serviceconnection"
    private_connection_resource_id = azurerm_postgresql_server.appsocpostgresserver.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.appsocdns.id]
  }
  depends_on = [azurerm_postgresql_server.appsocpostgresserver]
}
resource "azurerm_private_dns_zone" "appsocdns" {
  name                = "appsocprivatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  depends_on          = [azurerm_postgresql_server.appsocpostgresserver]
}
resource "azurerm_private_dns_zone_virtual_network_link" "appsocdnslink" {
  name                  = "appsocdns-link"
  resource_group_name   = azurerm_resource_group.appsoc_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.appsocdns.name
  virtual_network_id    = azurerm_virtual_network.appsoc_vnet.id
  depends_on            = [azurerm_postgresql_server.appsocpostgresserver]
}


resource "azurerm_postgresql_firewall_rule" "appsocfirewall" {
  name                = "appsocfirewall"
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  server_name         = azurerm_postgresql_server.appsocpostgresserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "tls_private_key" "appsocssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "azurerm_ssh_public_key" "appsocssh" {
  name                = "myidrsa"
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  location            = azurerm_resource_group.appsoc_rg.location
  public_key          = tls_private_key.appsocssh.public_key_openssh
}
resource "azurerm_linux_virtual_machine" "appsocvm" {
  name                = "appsocvirtualmachine"
  resource_group_name = azurerm_resource_group.appsoc_rg.name
  location            = azurerm_resource_group.appsoc_rg.location
  size                = "Standard_F2"
  admin_username      = "appsocadmin"
  network_interface_ids = [
    azurerm_network_interface.pvtappsoc_nic[0].id,
  ]

  admin_ssh_key {
    username   = "appsocadmin"
    public_key = tls_private_key.appsocssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "kubernetes_pod" "docapp" {
  metadata {
    name = "docapp"
    labels = {
      name = "myapp"
    }
  }

  spec {
    container {
      image = "730335556195.dkr.ecr.us-east-1.amazonaws.com/ajaykumar-008:latest"
      name  = "myapp"

      port {
        container_port = 80
      }
    }

    image_pull_secrets {
      name = "docker-registry"
    }
  }
}

resource "kubernetes_service" "my_service" {
  metadata {
    name = "my-service"
  }

  spec {
    selector = {
      name = "myapp"
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type = "NodePort"

    node_port = 30001
  }
}