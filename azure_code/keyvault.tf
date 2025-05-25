# module "keyvault" {
#   source = "./modules/key_vault"
#   resource_group_name        = "python1234"
#   key_vault_name = "key-vault-tetr"
#   sku_name       = "premium"
#   hsm_key_name = "keyvauhsm"
#   key_size = 2048
#   key_type = "RSA-HSM"
#   enabled_for_deployment      = false
#   enabled_for_disk_encryption = false
#   enable_rbac_authorization   = false
#   purge_protection_enabled    = true
#   access_policies = [
#     {
#       key_permissions         = ["Create", "Get", "List", "SetRotationPolicy", "GetRotationPolicy", "Delete"]
#       secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
#       certificate_permissions = ["Get", "List"]
#     }
#   ]
#   key_vault_secrets = {
#     "db-password"  = "SuperSecretPassword!"
#     "api-key"      = "API-KEY-1234"
#     "storage-key"  = "StorageAccessKey=="
#   }
#   tags = {
#     owner       = "admin"
#   }
# }