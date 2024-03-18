variable "ami" {
  type    = string
  default = "ami-0d7a109bf30624c99"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "cidr_block" {
  type    = string
  default = "192.168.0.0/16"
}

variable "subnet_names" {
  type    = list(string)
  default = ["ajay", "akki", "anji"]

}