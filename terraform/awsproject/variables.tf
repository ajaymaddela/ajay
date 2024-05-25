variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"

}
variable "pub_subnet_names" {
  type    = list(string)
  default = [""]

}
variable "pvt_subnet_names" {
  type    = list(string)
  default = [""]

}
variable "role_arn" {
  type    = string
  default = ""

}
variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}