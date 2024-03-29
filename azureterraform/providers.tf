terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
   backend "azurerm" {
    resource_group_name  = "sample"
    storage_account_name = "ltqtbackendstorage"
    container_name       = "tfstate"
    key                  = "springpetclinic.tfstate"
  }
 
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {

  }
}