provider "aws" {
  region = "us-west-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  token                  = data.aws_eks_cluster_auth.eks_auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
}
resource "aws_iam_policy" "service_account1_policy" {
  name        = "ServiceAccount1Policy"
  description = "IAM policy for Service Account 1"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:ListAllMyBuckets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "service_account2_policy" {
  name        = "ServiceAccount2Policy"
  description = "IAM policy for Service Account 2"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:Scan",
        "dynamodb:Query"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "aws_eks_cluster" "eks" {
  name = "EKSCluster-ajay"
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = "EKSCluster-ajay"
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# # Create OIDC Provider
resource "aws_iam_openid_connect_provider" "eks" {
  url             = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "service_account1_role" {
  name = "ServiceAccount1Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:default:service-account-1"
        }
      }
    }]
  })
}

resource "aws_iam_role" "service_account2_role" {
  name = "ServiceAccount2Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:default:service-account-2"
        }
      }
    }]
  })
}


resource "aws_iam_role_policy_attachment" "attach_sa1" {
  policy_arn = aws_iam_policy.service_account1_policy.arn
  role       = aws_iam_role.service_account1_role.name
}

resource "aws_iam_role_policy_attachment" "attach_sa2" {
  policy_arn = aws_iam_policy.service_account2_policy.arn
  role       = aws_iam_role.service_account2_role.name
}

resource "kubernetes_service_account" "service_account1" {
  metadata {
    name      = "service-account-1"
    namespace = "default"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.service_account1_role.arn
    }
  }
}

resource "kubernetes_service_account" "service_account2" {
  metadata {
    name      = "service-account-2"
    namespace = "default"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.service_account2_role.arn
    }
  }
}

# resource "aws_iam_role" "service_account1_role" {
#   name = 

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Federated": "${data.aws_eks_cluster.eks.identity[0].oidc[0].issuer}"
#       },
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Condition": {
#         "StringEquals": {
#           "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:default:service-account-1"
#         }
#       }
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role" "service_account2_role" {
#   name = "ServiceAccount2Role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Federated": "${data.aws_eks_cluster.eks.identity[0].oidc[0].issuer}"
#       },
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Condition": {
#         "StringEquals": {
#           "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:default:service-account-2"
#         }
#       }
#     }
#   ]
# }
# EOF
# }