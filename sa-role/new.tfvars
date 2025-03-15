aws_region      = "us-east-1"
cluster_name    = "my-cluster"
vpc_id          = "vpc-044e1354454dcf63a"
subnet_ids      = ["subnet-0bac41167fc0864d0", "subnet-06033306d03a85e4d"]

iam_sa_roles = {
  admin = {
    role_name       = "eks-admin-role"
    namespace       = "kube-system"
    service_account = "admin-sa"
    policy_arns     = {
      policy1 = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    }
  }

  readonly = {
    role_name       = "eks-readonly-role"
    namespace       = "default"
    service_account = "readonly-sa"
    policy_arns     = {
      policy1 = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    }
  }
}

tags = {
  Environment = "Dev"
  Project     = "EKS-IRSA"
}
