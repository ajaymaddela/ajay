variable "cluster_identifier" {
  type    = string
  default = ""

}
variable "engine" {
  type    = string
  default = ""

}
variable "engine_mode" {
  type    = string
  default = ""

}
variable "master_username" {
  type    = string
  default = ""

}
variable "master_password" {
  type    = string
  default = ""

}

variable "skip_final_snapshot" {
  type    = bool
  default = null

}
variable "availability_zones" {
  type    = list(string)
  default = [""]

}
variable "cluster_instance_identifier1" {
  type    = string
  default = ""

}
variable "cluster_instance_identifier2" {
  type    = string
  default = ""

}
variable "instance_class" {
  type    = string
  default = ""

}
variable "fis_role_name" {
  type    = string
  default = ""

}
variable "fis_policy_name" {
  type    = string
  default = ""

}
variable "rds_role_name" {
  type    = string
  default = ""

}
variable "feature_name" {
  type    = string
  default = ""

}
