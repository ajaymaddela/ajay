variable "eks_name" {
  type    = string
  default = "ajay"
}
variable "role_arn" {
  type    = string
  default = "arn:aws:iam::905418198314:role/eksajay"
}
variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-07fa28f15701170cb", "subnet-06d69c59fbf19c4a0"]
}