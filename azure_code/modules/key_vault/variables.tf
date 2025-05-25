# variable "resource_group_name" {
#   description = "Name of the existing resource group"
#   type        = string
# }

# variable "key_vault_name" {
#   description = "Name of the Azure Key Vault"
#   type        = string
# }

# variable "sku_name" {
#   description = "SKU for Azure Key Vault (standard/premium)"
#   type        = string
#   default     = "standard"
# }

# variable "enabled_for_deployment" {
#   description = "Enable Key Vault for VM deployment"
#   type        = bool
#   default     = false
# }

# variable "enabled_for_disk_encryption" {
#   description = "Enable Key Vault for disk encryption"
#   type        = bool
#   default     = false
# }

# variable "enable_rbac_authorization" {
#   description = "Enable RBAC authorization for Key Vault"
#   type        = bool
#   default     = false
# }

# variable "purge_protection_enabled" {
#   description = "Enable Purge Protection for Key Vault"
#   type        = bool
#   default     = true
# }

# variable "hsm_key_name" {
#   description = "Name of the HSM-backed key"
#   type        = string
#   default = ""
# }

# variable "key_type" {
#   type = string
#   default = ""
# }

# variable "key_size" {
#   type = number
#   default = 2048
# }
# variable "tags" {
#   description = "Tags for resources"
#   type        = map(string)
#   default     = {}
# }

# variable "access_policies" {
#   description = "List of Key Vault access policies"
#   type = list(object({
#     key_permissions         = list(string)
#     secret_permissions      = list(string)
#     certificate_permissions = list(string)
#   }))
#   default = []
# }

# variable "key_vault_secrets" {
#   description = "Map of Key Vault secrets (name = value)"
#   type        = map(string)
# }