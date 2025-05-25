provider "azurerm" {
  features {}
  subscription_id = "fc3acc55-41d9-4150-8f51-6588e3da9612"
}

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "tf-state-rg"
#     storage_account_name = "tfstateaccount"
#     container_name       = "tfstate"
#     key                  = "keyvault.terraform.tfstate"
#   }
# }