variable "cluster_name" {
  type = string
  default = "m-prod"
}

variable "cluster_version" {
  type = string
  default = "1.30"
}

variable "eks_public_subnets" {
  type = list(string)
  default = ["subnet-xxxxxxxxxxxxx", "subnet-xxxxxxxxxxxxx"]
}

variable "eks_vpc_id" {
  type = string
  default = "vpc-xxxxxxxxxxxxx"
}
variable "main-region" {
  type       = string
  default    = "us-east-1"
}

variable "env_name" {
  default = "alb"
  type    = string
}


################################################################################
# Variables from other Modules
################################################################################
