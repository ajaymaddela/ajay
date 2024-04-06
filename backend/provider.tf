terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.97.1"
    }
  }
}

provider "azurerm" {
  features {
    
  }
}
terraform {
  backend "azurerm" {
    resource_group_name = "ajay"
    storage_account_name = "ltqt"
    container_name = "ltqtgt"
    key = "nop.terraform.tfstate"
    
  }
}