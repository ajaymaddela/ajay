variable "allocated_storage" {
  type    = number
  default = null

}
variable "db_name" {
  type    = string
  default = ""

}
variable "engine" {
  type    = string
  default = ""

}
variable "engine_version" {
  type    = string
  default = ""

}
variable "instance_class" {
  type    = string
  default = ""

}
variable "username" {
  type    = string
  default = ""

}
variable "password" {
  type    = string
  default = ""

}
variable "parameter_group_name" {
  type    = string
  default = ""

}
variable "skip_final_snapshot" {
  type    = bool
  default = null

}