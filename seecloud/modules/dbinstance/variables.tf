variable "aws_db_instance_class" {
  type = string
  default = ""
}
variable "allocated_storage_store" {
    type = number
    default = null
  
}
variable "db_name_name" {
    type = string
    default = ""
  
}
variable "engine_name" {
    type = string
    default = ""
  
}
variable "engine_version_ver" {
    type = string
    default = ""
  
}
variable "username_name" {
    type = string
    default = ""
  
}
variable "password_key" {
    type = string
    default = ""
  
}
variable "parameter_group_name_nsm" {
    type = string
    default = ""
  
}
variable "skip_final_snapshot_snap" {
    type = bool
    default = null
  
}
variable "ami_id" {
    type = string
    default = ""
  
}
variable "instance_type_type" {
    type = string
    default = ""
  
}