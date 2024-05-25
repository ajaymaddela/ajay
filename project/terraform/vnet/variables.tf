variable "resource_group_name" {
  type    = string
  default = ""
}


variable "region" {
  type        = string
  default     = ""
  description = "in which area region is located"

}
variable "pub_subnet_names" {
  type    = list(string)
  default = [""]

}
variable "pvt_subnet_names" {
  type    = list(string)
  default = [""]

}
variable "network_cidr" {
  type    = string
  default = "10.20.0.0/16"
}
variable "virtual_network_name" {
  type    = string
  default = ""

}
variable "public_ip_name" {
  type    = string
  default = ""

}
variable "appsoc_nat" {
  type    = string
  default = ""

}
variable "sku_name" {
  type    = string
  default = ""

}
variable "idle_timeout_in_minutes" {
  type    = number
  default = null

}
variable "zones_required" {
  type    = list(string)
  default = [""]

}
variable "network_security_group" {
  type    = string
  default = ""

}
variable "network_security_group_rule" {
  type    = string
  default = ""

}
variable "priority_number" {
  type    = number
  default = null

}
variable "direction" {
  type    = string
  default = ""
}
variable "access_rule" {
  type    = string
  default = ""

}
variable "protocol" {
  type    = string
  default = ""

}
variable "source_port_range" {
  type    = string
  default = ""

}
variable "destination_port_range" {
  type    = string
  default = ""

}
variable "source_address_prefix" {
  type    = string
  default = ""

}
variable "destination_address_prefix" {
  type    = string
  default = ""

}
variable "network_interface" {
  type    = string
  default = ""

}
variable "ipconfig" {
  type    = string
  default = ""

}
variable "route_table" {
  type    = string
  default = ""

}

variable "route_name" {
  type    = string
  default = ""

}
variable "address_prefix" {
  type    = string
  default = ""

}
variable "next_hop_type" {
  type    = string
  default = ""

}

variable "next_hop_in_ip_address" {
  type    = string
  default = ""

}
variable "pvt_subnet_cidrs" {
  type    = list(string)
  default = []

}
variable "pub_subnet_cidrs" {
  type    = list(string)
  default = []

}

variable "kubernetescluster_name" {
  type    = string
  default = ""

}
variable "node_name" {
  type    = string
  default = ""

}
variable "vm_size" {
  type    = string
  default = ""

}
variable "node_count" {
  type    = number
  default = null

}
variable "dns_prefix_name" {
  type    = string
  default = ""

}
variable "identity" {
  type    = string
  default = ""

}

variable "application_gateway" {
  type    = string
  default = ""

}
variable "sku_apg" {
  type    = string
  default = ""

}

variable "sku_tier" {
  type    = string
  default = ""

}
variable "sku_capacity" {
  type    = number
  default = null

}
variable "gatewayip_name" {
  type    = string
  default = ""

}
variable "frontend_name" {
  type    = string
  default = ""

}
variable "frontend_port" {
  type    = number
  default = null

}
variable "frontendip_name" {
  type    = string
  default = ""

}
variable "backend_name" {
  type    = string
  default = ""

}
variable "backendhttp_name" {
  type    = string
  default = ""

}
variable "cookie_based" {
  type    = string
  default = ""

}
variable "backend_port" {
  type    = number
  default = null

}
variable "http_name" {
  type    = string
  default = ""

}