variable "eks_name" {
  type    = string
  default = "ajay"
}
variable "role_arn" {
  type    = string
  default = 
}
variable "subnet_ids" {
  type    = list(string)
  default = ["subnet-07fa28f15701170cb", "subnet-06d69c59fbf19c4a0"]
}