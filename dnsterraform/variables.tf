variable "vpc_cidr" {
  type    = string
  default = ""

}

variable "private_subnet_cidr" {
  type    = string
  default = ""

}

variable "availability_zone" {
  type    = string
  default = ""

}

variable "ami_id" {
  type    = string
  default = ""

}

variable "instance_type" {
  type    = string
  default = ""

}

variable "domain_name" {
  type    = string
  default = ""

}

variable "domain_name_servers_ip" {
  type    = list(string)
  default = [""]
}

variable "ip_for_transit" {
  type    = string
  default = ""

}