# # data "azurerm_client_config" "current" {
# # }

# # # Fetch Existing Resource Group
# # data "azurerm_resource_group" "existing_rg" {
# #   name = var.resource_group_name
# # }

# # resource "azurerm_key_vault" "kv" {
# #   name                        = lower("kv-${var.key_vault_name}")
# #   location                    = data.azurerm_resource_group.existing_rg.location
# #   resource_group_name         = data.azurerm_resource_group.existing_rg.name
# #   tenant_id                   = data.azurerm_client_config.current.tenant_id
# #   sku_name                    = var.sku_name
# #   enabled_for_deployment      = var.enabled_for_deployment
# #   enabled_for_disk_encryption = var.enabled_for_disk_encryption
# #   enable_rbac_authorization   = var.enable_rbac_authorization
# #   purge_protection_enabled    = var.purge_protection_enabled
# #   tags                        = var.tags

# #   dynamic "access_policy" {
# #     for_each = var.enable_rbac_authorization ? [] : var.access_policies
# #     content {
# #       tenant_id               = data.azurerm_client_config.current.tenant_id
# #       object_id               = data.azurerm_client_config.current.object_id
# #       key_permissions         = access_policy.value.key_permissions
# #       secret_permissions      = access_policy.value.secret_permissions
# #       certificate_permissions = access_policy.value.certificate_permissions
# #     }
# #   }
# # }

# # resource "azurerm_key_vault_key" "hsm_key" {
# #   name         = var.hsm_key_name
# #   key_vault_id = azurerm_key_vault.kv.id
# #   key_type     = var.key_type
# #   key_size     = var.key_size

# #   key_opts = [
# #     "decrypt",
# #     "encrypt",
# #     "sign",
# #     "unwrapKey",
# #     "verify",
# #     "wrapKey",
# #   ]

# #   rotation_policy {
# #     automatic {
# #       time_before_expiry = "P30D"
# #     }

# #     expire_after         = "P90D"
# #     notify_before_expiry = "P29D"
# #   }
# #   depends_on = [ azurerm_key_vault.kv ]
# # }

# # # Key Vault Secrets
# # resource "azurerm_key_vault_secret" "secrets" {
# #   for_each     = var.key_vault_secrets
# #   name         = each.key
# #   value        = each.value
# #   key_vault_id = azurerm_key_vault.kv.id
# #   depends_on = [ azurerm_key_vault_key.hsm_key ]
# # }


# # Configure Azure provider
# provider "azurerm" {
#   features {
#     key_vault {
#       purge_soft_deleted_hardware_security_modules_on_destroy = true
#     }
#   }
# }

# # Get current Azure client configuration
# data "azurerm_client_config" "current" {}

# # Create Resource Group
# resource "azurerm_resource_group" "example" {
#   name     = "example-resources"
#   location = "West Europe"
# }

# # Create Managed HSM
# resource "azurerm_key_vault_managed_hardware_security_module" "example" {
#   name                       = "exampleKVHsm"
#   resource_group_name        = azurerm_resource_group.example.name
#   location                   = azurerm_resource_group.example.location
#   sku_name                   = "Standard_B1"
#   purge_protection_enabled   = true  # Recommended to enable for production
#   soft_delete_retention_days = 90
#   tenant_id                  = data.azurerm_client_config.current.tenant_id
#   admin_object_ids           = [data.azurerm_client_config.current.object_id]

#   tags = {
#     Env = "Test"
#   }
# }

# # Create a Key in the Managed HSM
# resource "azurerm_key_vault_managed_hsm_key" "hsm_key" {
#   name         = "hsm-encryption-key"
#   managed_hsm_id = azurerm_key_vault_managed_hardware_security_module.example.id
#   key_type     = "RSA-HSM"
#   key_size     = 2048
#   key_opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
# }

# # Create Azure Key Vault
# resource "azurerm_key_vault" "kv" {
#   name                        = lower("kv-example")
#   location                    = azurerm_resource_group.example.location
#   resource_group_name         = azurerm_resource_group.example.name
#   tenant_id                   = data.azurerm_client_config.current.tenant_id
#   sku_name                    = "standard"  # Standard SKU for Key Vault
#   enabled_for_deployment      = true
#   enabled_for_disk_encryption = true
#   enable_rbac_authorization   = true
#   purge_protection_enabled    = true
#   tags = {
#     Env = "Test"
#   }
# }

# # Key Vault Secrets
# resource "azurerm_key_vault_secret" "secrets" {
#   for_each     = {
#     "example-secret-1" = "secret-value-1"
#     "example-secret-2" = "secret-value-2"
#   }
#   name         = each.key
#   value        = each.value
#   key_vault_id = azurerm_key_vault.kv.id
# }

# # Output the HSM Key ID
# output "hsm_key_id" {
#   value = azurerm_key_vault_managed_hsm_key.hsm_key.id
# }

# # Output the Key Vault ID
# output "key_vault_id" {
#   value = azurerm_key_vault.kv.id
# }

# # Key Vault Secrets
# resource "azurerm_key_vault_secret" "secrets" {
#   for_each     = var.key_vault_secrets
#   name         = each.key
#   value        = each.value
#   key_vault_id = azurerm_key_vault.kv.id
#   depends_on   = [azurerm_key_vault.kv]
# }

