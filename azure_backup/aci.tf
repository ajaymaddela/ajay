resource "azurerm_subnet" "aci_subnet" {
  name                 = "aci-subnet"
  resource_group_name  = module.network.resource_group_name_output
  virtual_network_name = module.network.vnet_name
  address_prefixes     = ["10.0.20.0/24"] # Adjust to your actual CIDR

  delegation {
    name = "aci-delegation"
    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
module "aci" {
  source = "./aci"

  container_instance_name = "testing"
  location                = module.network.region_output
  rg_name                 = module.network.resource_group_name_output
  os_type                 = "Linux"
  restart_policy          = "Always"
  # vnet_integration_enabled = true
  ip_address_type         = "Public"
  # subnet_ids              = [azurerm_subnet.aci_subnet.id]
  dns_name_label          = "tsethw"
  identity_type           = "SystemAssigned"
  identity_ids            = []
  
  settings = {
    image_registry_credential = {
      username     = "ajaykumar020"
      password     = "Ajay#0008"
      login_server = "index.docker.io"
    }
   
  #   diagnostics = {
  #     log_analytics = {
  #       workspace_id  = "workspace-id"
  #       workspace_key = "workspace-key"
  #     }
  #   }
  
    exposed_port = {
      port     = 80
      protocol = "TCP"
    }
  
    containers = [
      {
        name   = "main-container"
        image  = "nginx:latest"
        cpu    = "0.5"
        memory = "1.5"
  
        ports = [
          {
            port     = 80
            protocol = "TCP"
          }
        ]
  
      #   volume = {
      #     name       = "code-volume"
      #     mount_path = "/app"
      #     git_repo = {
      #       url       = "https://github.com/user/repo.git"
      #       directory = "/app"
      #       revision  = "main"
      #     }
      #   }
      }
    ]
  
  #   init_container = {
  #     name  = "init"
  #     image = "busybox"
  #     commands = ["/bin/sh", "-c", "echo Init container started"]
  
  #     volume = {
  #       name       = "init-volume"
  #       mount_path = "/init"
  #       git_repo = {
  #         url       = "https://github.com/user/repo.git"
  #         directory = "/init"
  #         revision  = "main"
  #       }
  #     }
  #   }
  
    # container_network_interface = {
    #   name = "aci-nic"
    #   ip_configuration = {
    #     name      = "aci-ipconfig"
    #     subnet_id = module.network.public_subnets[0]
    #   }
    # }
  }
}


#################
# resource "azurerm_container_group" "aci" {
#   container_instance_name = "testing"
#   location               = module.network.region_output
#   rg_name                = module.network.resource_group_name_output
#   os_type                = "Linux"
#   restart_policy         = "Always"
#   vnet_integration_enabled = false
#   ip_address_type        = "Public"
#   dns_name_label         = "tsethw"
#   identity_type          = "SystemAssigned"
#   identity_ids           = []

#   settings = {
#     image_registry_credential = {
#       username     = "ajaykumar020"
#       password     = "Ajay#0008"
#       login_server = "index.docker.io"
#     }

#     exposed_port = {
#       port     = 80
#       protocol = "TCP"
#     }

#     containers = [
#       {
#         name   = "main-container"
#         image  = "nginx:latest"
#         cpu    = "0.5"
#         memory = "1.5"

#         ports = [
#           {
#             port     = 80
#             protocol = "TCP"
#           }
#         ]
#       }
#     ]
#   }
# }
