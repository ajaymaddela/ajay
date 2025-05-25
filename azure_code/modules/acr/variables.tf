variable "resource_group" {
  description = "Name of the existing resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the existing virtual network"
  type        = string
  default = null
}

variable "subnet_name" {
  description = "Name of the existing subnet to use for private endpoint"
  type        = string
  default = null
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "sku" {
  description = "SKU of the ACR (e.g., Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Enable admin user for ACR"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access to ACR"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "encryption_enabled" {
  description = "Enable customer-managed key (CMK) encryption"
  type        = bool
  default     = false
}

variable "key_vault_key_id" {
  description = "Key Vault key ID for CMK encryption"
  type        = string
  default     = null
}

variable "network_rule_set" {
  description = "Optional network rules (ip_rules list and default_action)"
  type = object({
    default_action = string
    ip_rules = list(object({
      action   = string
      ip_range = string
    }))
  })
  default = null
}

variable "enable_private_endpoint" {
  description = "Create private endpoint for ACR"
  type        = bool
  default     = false
}

variable "enable_diagnostics" {
  description = "Enable diagnostic settings for ACR"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "scope_map" {
  description = "Map of scope maps to create ACR tokens for. Each key is the scope name and value includes actions."
  type = map(object({
    actions = list(string)
  }))
  default = {} 
}

