variable "resource_group" {
  description = "Name of the existing resource group."
  type        = string
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
  default = ""
}

variable "storage_container_name" {
  type        = string
  default     = null
  description = "The name of the storage container"
}

variable "app_service_name" {
  description = "Name of the web app (will be prefixed with 'app-')."
  type        = string
  default = ""
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan."
  type        = string
  default = ""
}

variable "os_type" {
  description = "OS type for the app service (must be 'Linux' or 'Windows')."
  type        = string
  default = ""
}

variable "per_site_scaling" {
  type = bool
}


variable "app_command_line" {
  type        = string
  default     = null
  description = "The command line to run the app"
}

variable "application_insights_enabled" {
  description = "Enable Application Insights integration."
  type        = bool
  default     = false
}

variable "application_insights_id" {
  description = "ID of the existing Application Insights resource."
  type        = string
  default     = null
}

variable "app_insights_name" {
  description = "Name for the Application Insights resource."
  type        = string
  default = ""
}

variable "application_insights_type" {
  description = "Type of Application Insights (e.g., 'web')."
  type        = string
  default     = ""
}

variable "retention_in_days" {
  description = "Retention period for Application Insights data."
  type        = number
  default     = 90
}

variable "disable_ip_masking" {
  description = "Disable IP masking for Application Insights."
  type        = bool
  default     = false
}

variable "app_settings" {
  description = "Application settings for the web app."
  type        = map(string)
  default     = {}
}

variable "default_documents" {
  description = "List of default documents for the web app."
  type        = list(string)
  default     = []
}

variable "health_check_path" {
  description = "Path for health check endpoint."
  type        = string
  default     = "/"
}

variable "http2_enabled" {
  description = "Enable HTTP/2 for the web app."
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS for the web app."
  type        = bool
  default     = true
}

variable "ips_allowed" {
  description = "List of IP CIDRs allowed to access the app."
  type        = list(string)
  default     = []
}

variable "subnet_ids_allowed" {
  description = "List of subnet IDs allowed to access the app."
  type        = list(string)
  default     = []
}

variable "service_tags_allowed" {
  description = "List of service tags allowed to access the app."
  type        = list(string)
  default     = []
}

variable "scm_ips_allowed" {
  description = "List of IP CIDRs allowed for SCM access."
  type        = list(string)
  default     = []
}

variable "scm_subnet_ids_allowed" {
  description = "List of subnet IDs allowed for SCM access."
  type        = list(string)
  default     = []
}

variable "scm_service_tags_allowed" {
  description = "List of service tags allowed for SCM access."
  type        = list(string)
  default     = []
}

variable "enable_auth_settings" {
  description = "Enable authentication settings."
  type        = bool
  default     = false
}

variable "enable_application_stack" {
  description = "Enable application stack configuration"
  type        = bool
  default     = false
}

variable "application_stack" {
  description = "Application stack configuration"
  type = map(string)
  default = {
    docker_image_name        = ""
    docker_registry_username = ""
    docker_registry_password = ""
    docker_registry_url      = ""
    dotnet_version           = ""
    java_version             = ""
    node_version             = ""
    php_version              = ""
    python_version           = ""
    ruby_version             = ""
  }
}

variable "default_auth_provider" {
  description = "Default authentication provider."
  type        = string
  default     = ""
}

variable "unauthenticated_client_action" {
  description = "Action for unauthenticated clients."
  type        = string
  default     = ""
}

variable "token_store_enabled" {
  description = "Enable token store."
  type        = bool
  default     = false
}

variable "active_directory_auth_settings" {
  description = "Settings for Active Directory authentication."
  type = list(object({
    client_id         = string
    client_secret     = string
    allowed_audiences = list(string)
  }))
  default = []
}

variable "enable_backup" {
  description = "Enable backup for the web app."
  type        = bool
  default     = false
}


variable "backup_settings" {
  description = "Configuration for backup settings."
  type = object({
    name                = string
    enabled             = bool
    frequency_interval  = number
    frequency_unit      = string
    start_time          = string
  })
  default = null
}

variable "connection_strings" {
  description = "List of connection strings for the web app."
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
}
variable "enable_identity" {
  type    = bool
  default = true
}

variable "storage_mounts" {
  description = "List of storage mounts for the web app."
  type = list(object({
    name         = string
    type         = string
    account_name = string
    share_name   = string
    access_key   = string
    mount_path   = string
  }))
  default = []
}

variable "custom_domains" {
  description = "Map of custom domains and their certificate configurations."
  type = map(object({
    certificate_file                  = optional(string)
    certificate_password              = optional(string)
    certificate_keyvault_certificate_id = optional(string)
  }))
  default = {}
}

variable "enable_vnet_integration" {
  description = "Enable VNet integration."
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for VNet integration."
  type        = string
  default     = null
}

variable "password_end_date" {
  description = "End date for password rotation."
  type        = string
  default = ""
}

variable "password_rotation_in_years" {
  description = "Number of years for password rotation."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to assign to the resources."
  type        = map(string)
  default     = {}
}