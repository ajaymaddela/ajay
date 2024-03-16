variable "ami" {
  type    = string
  default = "web"
}

variable "aws_instance" {
  type    = string
  default = "web"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "cidr_block" {
  type    = string
  default = "192.168.0.0/16"
}
variable "subnet_cidrs" {
  type    = string
  default = "192.168.0.0/24"


}
