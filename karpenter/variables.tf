variable "cluster_name" {
  type = string
  default = "md-prod"
}

variable "cluster_version" {
  type = string
  default = "1.29"
}

variable "eks_public_subnets" {
  type = list(string)
  default = ["subnet-0c2e7124c80535414", "subnet-087b9b23373d9a476"]
}

variable "eks_vpc_id" {
  type = string
  default = "vpc-0da9c0111d4428c4d"
}


# subnet-012d74719b30ef5aa

# subnet-0dbf590095292076c

# vpc-0ea636f8cc198e09b