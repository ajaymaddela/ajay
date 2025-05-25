variable "container_instance_name" {
  description = "The name of the Azure Container Instance"
  type        = string
}

variable "location" {
  description = "Azure region to deploy the resources"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "os_type" {
  description = "OS type for the container. Allowed values: Linux or Windows"
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either 'Linux' or 'Windows'."
  }
}

variable "restart_policy" {
  description = "Restart policy for container group. Allowed values: Always, OnFailure, Never"
  type        = string
  default     = "Always"
  validation {
    condition     = contains(["Always", "OnFailure", "Never"], var.restart_policy)
    error_message = "restart_policy must be 'Always', 'OnFailure', or 'Never'."
  }
}

variable "key_vault_key_id" {
  description = "Optional Key Vault key ID for encryption"
  type        = string
  default     = null
}

variable "vnet_integration_enabled" {
  description = "Enable VNet integration for ACI"
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "IP address type (Public or Private)"
  type        = string
  default     = "Public"
  validation {
    condition     = contains(["Public", "Private"], var.ip_address_type)
    error_message = "ip_address_type must be either 'Public' or 'Private'."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for VNet integration"
  type        = list(string)
  default     = []
}

variable "dns_name_label" {
  description = "DNS name label for the container group (used when public IP)"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "Type of identity to use. Valid values: SystemAssigned, UserAssigned"
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = contains(["SystemAssigned", "UserAssigned"], var.identity_type)
    error_message = "identity_type must be either 'SystemAssigned' or 'UserAssigned'."
  }
}

variable "identity_ids" {
  description = "List of user-assigned managed identity IDs (required if identity_type is UserAssigned)"
  type        = list(string)
  default     = []
}

variable "network_profile_name" {
  description = "Name of the legacy network profile (if used)"
  type        = string
  default     = "aci-net-profile"
}

variable "use_legacy_network_profile" {
  description = "Whether to use legacy network profile"
  type        = bool
  default     = false
}

variable "settings" {
  description = "Advanced container group settings"
  type = object({
    image_registry_credential = optional(object({
      username     = string
      password     = string
      login_server = string
    }))
    dns_config = optional(object({
      nameservers    = list(string)
      search_domains = list(string)
      options        = list(string)
    }))
    diagnostics = optional(object({
      log_analytics = object({
        workspace_id  = string
        workspace_key = string
      })
    }))
    exposed_port = optional(object({
      port     = number
      protocol = string
    }))
    containers = list(object({
      name                         = string
      image                        = string
      cpu                          = number
      memory                       = number
      environment_variables        = optional(map(string))
      secure_environment_variables = optional(map(string))
      commands                     = optional(list(string))
      ports = optional(list(object({
        port     = number
        protocol = string
      })))
      gpu = optional(object({
        count = number
        sku   = string
      }))
      readiness_probe = optional(object({
        exec                  = optional(list(string))
        initial_delay_seconds = number
        period_seconds        = number
        failure_threshold     = number
        success_threshold     = number
        timeout_seconds       = number
        http_get = optional(object({
          path   = string
          port   = number
          scheme = string
        }))
      }))
      liveness_probe = optional(object({
        exec                  = optional(list(string))
        initial_delay_seconds = number
        period_seconds        = number
        failure_threshold     = number
        success_threshold     = number
        timeout_seconds       = number
        http_get = optional(object({
          path   = string
          port   = number
          scheme = string
        }))
      }))
      volume = optional(object({
        name                 = string
        mount_path           = string
        read_only            = optional(bool)
        empty_dir            = optional(bool)
        storage_account_name = optional(string)
        storage_account_key  = optional(string)
        share_name           = optional(string)
        secret               = optional(map(string))
        git_repo = optional(object({
          url       = string
          directory = string
          revision  = string
        }))
      }))
    }))
    init_container = optional(object({
      name                         = string
      image                        = string
      environment_variables        = optional(map(string))
      secure_environment_variables = optional(map(string))
      commands                     = optional(list(string))
      volume = optional(object({
        name                 = string
        mount_path           = string
        read_only            = optional(bool)
        empty_dir            = optional(bool)
        storage_account_name = optional(string)
        storage_account_key  = optional(string)
        share_name           = optional(string)
        secret               = optional(map(string))
        git_repo = optional(object({
          url       = string
          directory = string
          revision  = string
        }))
      }))
    }))
    container_network_interface = optional(object({
      name = string
      ip_configuration = optional(object({
        name      = string
        subnet_id = string
      }))
    }))
  })
  default = null
}
