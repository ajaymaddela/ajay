resource "azurerm_storage_account" "diag_storage" {
  name                     = "diagstorage${random_string.suffix.result}"
  resource_group_name      = var.resource_group
  location                 = var.region
  account_tier             = var.storage_account_tier
  account_replication_type = "LRS"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
