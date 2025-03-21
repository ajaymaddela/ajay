
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "log-workspace"
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "PerGB2018"
}

resource "azurerm_storage_account" "diag_storage" {
  name                     = "diagstorage${random_string.suffix.result}"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}
