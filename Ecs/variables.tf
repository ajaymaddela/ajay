variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  default = "my-ecs-cluster"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for EC2 access"
  type        = string
  default = "hp"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
