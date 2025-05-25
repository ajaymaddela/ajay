provider "azurerm" {
  features {}
  subscription_id = ""
}

terraform {
  required_providers {
    time = {
      source  = "hashicorp/time"
     
    }
  }
}
