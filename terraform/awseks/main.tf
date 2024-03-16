resource "aws_eks_cluster" "cluster" {
  name     = var.eks_name
  role_arn = var.role_arn
  vpc_config {
    subnet_ids = var.subnet_ids
  }
  outpost_config {
    control_plane_instance_type = "t2.large"
    outpost_arns                = ["var.role_arn"]
  }


}




