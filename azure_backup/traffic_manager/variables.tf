variable "resource_group" {
  description = "Resource Group name for Traffic Manager"
  type        = string
}

variable "vnet_name" {
  type = string
  default = ""
}

variable "subnet_name" {
  type = string
  default = ""
}

variable "traffic_manager_name" {
  description = "Name of the Traffic Manager profile"
  type        = string
}

variable "traffic_routing_method" {
  description = "Traffic routing method (e.g., Performance, Priority, Weighted)"
  type        = string
}

variable "relative_dns_name" {
  description = "Relative DNS name for Traffic Manager"
  type        = string
}

variable "tm_ttl" {
  description = "TTL for the DNS configuration"
  type        = number
}

variable "monitor_protocol" {
  description = "Monitor protocol (HTTP, HTTPS, TCP)"
  type        = string
}

variable "monitor_port" {
  description = "Monitor port"
  type        = number
}

variable "monitor_path" {
  description = "Monitor path for health probe"
  type        = string
}

variable "use_external_endpoint" {
  description = "Whether to use an external endpoint"
  type        = bool
}

variable "external_endpoint_name" {
  description = "Name of the external endpoint"
  type        = string
  default = ""
}

variable "external_endpoint_weight" {
  description = "Weight of the external endpoint"
  type        = number
  default = 0
}

variable "external_endpoint_always_serve" {
  description = "Whether the external endpoint should always serve traffic"
  type        = bool
  default = false
}

variable "external_endpoint_target" {
  description = "Target FQDN or public IP of the external endpoint"
  type        = string
  default = ""
}

variable "use_azure_endpoint" {
  description = "Whether to use an Azure endpoint"
  type        = bool
  default = false
}

variable "azure_endpoint_name" {
  description = "Name of the Azure endpoint"
  type        = string
  default = ""
}

variable "azure_endpoint_resource_id" {
  description = "Resource ID of the Azure endpoint target"
  type        = string
  default = ""
}

variable "azure_endpoint_weight" {
  description = "Weight of the Azure endpoint"
  type        = number
  default = 0
}

variable "azure_endpoint_priority" {
  description = "Priority of the Azure endpoint"
  type        = number
  default = 0
}

variable "azure_endpoint_enabled" {
  description = "Enable or disable the Azure endpoint"
  type        = bool
  default = false
}

variable "azure_endpoint_always_serve" {
  description = "Whether the Azure endpoint should always serve traffic"
  type        = bool
  default = false
}

variable "azure_endpoint_geo_mappings" {
  description = "Geo-mappings for Azure endpoint"
  type        = list(string)
  default     = []
}

variable "create_custom_domain_dns" {
  description = "Flag to create a custom DNS zone and CNAME"
  type        = bool
  default = false
}

variable "dns_zone_name" {
  description = "Name of the DNS zone"
  type        = string
  default = ""
}

variable "cname_record_name" {
  description = "Name of the CNAME record"
  type        = string
  default = ""
}

variable "create_dns_a_record" {
  type = bool
  default = true
}

variable "a_record_name" {
  type = string
  default = "testing"
}

variable "cname_record_ttl" {
  description = "TTL for the CNAME record"
  type        = number
  default = null
}

variable "a_record_ttl" {
  type = number
  default = 300
}

variable "dns_a_record" {
  type = list(string)
  default = null
}