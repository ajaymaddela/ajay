resource "azurerm_resource_group" "ajay" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_kubernetes_cluster" "ajay" {
  name                = var.kubernetescluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  default_node_pool {
    name       = "nodepool"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
  dns_prefix = "akkiaks1"
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "Production"
  }
  provisioner "local-exec" {
   command = "az aks get-credentials --resource-group demo-resources --name myAKSCluster"
       
  }
  depends_on = [azurerm_resource_group.ajay]
}
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.ajay.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.ajay.kube_config_raw

  sensitive = true
}