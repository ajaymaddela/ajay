provider "aws" {
  region = "us-west-1"
}

resource "aws_iam_role" "NodeGroupRole" {
  name = "EKSNodeRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.NodeGroupRole.name
}

# resource "aws_iam_role_policy_attachment" "admin" {
#   policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
#   role = aws_iam_role.NodeGroupRole.name
# }


resource "aws_iam_role" "EKSClusterRole" {
  name = "EKSk8sRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKSClusterRole.name
}



resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "eks-vpc"
    Environment = "dev"
  }
}

resource "aws_subnet" "eks_public" {
  count                   = 2
  availability_zone       = element(["us-west-1a", "us-west-1b"], count.index)
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.eks_vpc.id

  tags = {
    Name        = "eks-public-${count.index}"
    Environment = "dev"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "eks_private" {
  count             = 2
  availability_zone = element(["us-west-1a", "us-west-1b"], count.index)
  cidr_block        = "10.0.${count.index + 2}.0/24"
  vpc_id            = aws_vpc.eks_vpc.id

  tags = {
    Name        = "eks-private-${count.index}"
    Environment = "dev"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = 1
  subnet_id      = aws_subnet.eks_public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "node_group" {
  name_prefix = "nodesg"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_cluster" "EKSCluster" {
  name     = "EKSCluster-ajay"
  role_arn = aws_iam_role.EKSClusterRole.arn
  vpc_config {
    subnet_ids = aws_subnet.eks_private.*.id
    endpoint_private_access = true
    endpoint_public_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.EKSCluster.name
  addon_name   = "vpc-cni"
  depends_on = [ aws_eks_cluster.EKSCluster ]
}

# resource "aws_eks_addon" "coredns" {
#   cluster_name = aws_eks_cluster.EKSCluster.name
#   addon_name   = "coredns"
# }

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.EKSCluster.name
  addon_name   = "kube-proxy"
  depends_on = [ aws_eks_cluster.EKSCluster ]
}

resource "aws_eks_node_group" "NodeGroup1" {
  cluster_name    = aws_eks_cluster.EKSCluster.name
  node_group_name = "NodeGroup12"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = aws_subnet.eks_private.*.id
  # instance_types  = ["t2.medium"]
  
  launch_template {
    id = aws_launch_template.eks_launch_template.id
    version = aws_launch_template.eks_launch_template.latest_version
    
  }
  # ami_type = "AL2_x86_64"
  # capacity_type = "ON_DEMAND"
  # disk_size = "10"

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_route_table_association.private,
    aws_nat_gateway.nat_gw
  ]
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_launch_template" "eks_launch_template" {
  name                 = "eks-launch-template"
  
  # image_id             = "ami-0030945a5e6d38ef4" # Update this to the correct EKS AMI
  vpc_security_group_ids = [aws_security_group.node_group.id, aws_eks_cluster.EKSCluster.vpc_config[0].cluster_security_group_id]
 image_id = "ami-0cd606c810b9a5d3a"
   block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 10
      volume_type = "gp2"
    }
  }
 key_name = "dellwest"
 instance_type = "t2.medium"
  user_data = base64encode(<<-EOF
       #!/bin/bash
       /etc/eks/bootstrap.sh ${aws_eks_cluster.EKSCluster.name}
      EOF
  )

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_eip" "nat_eip" {
  # vpc = true
  tags = {
    Name = "nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.eks_public[0].id # Place NAT Gateway in one of the public subnets
  tags = {
    Name = "nat-gateway"
  }
  depends_on = [ aws_eip.nat_eip ]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-route-table"
  }
  depends_on = [ aws_eip.nat_eip ]
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.eks_private)
  subnet_id      = aws_subnet.eks_private[count.index].id
  route_table_id = aws_route_table.private.id
  depends_on = [ aws_nat_gateway.nat_gw ]
}

resource "aws_instance" "bastion_host" {
  vpc_security_group_ids = [ aws_security_group.node_group.id ]
  key_name = "dellwest"
  associate_public_ip_address = true
  subnet_id = aws_subnet.eks_public[0].id
  tags = {
    "env" = "ajay"
  }
  ami = "ami-03d49b144f3ee2dc4"
  instance_type = "t2.medium"
  depends_on = [ aws_security_group.node_group ]
}


# # After clutser creation excute below on batsion host
# provider "aws" {
#   region = "us-west-1"
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.cluster.endpoint
#   token                  = data.aws_eks_cluster_auth.cluster.token
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
# }

# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     token                  = data.aws_eks_cluster_auth.cluster.token
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
#   }
# }

# # Variables
# variable "aws_region" {
#   description = "AWS region where resources will be created"
#   type        = string
#   default     = "us-west-1"
# }

# variable "cluster_name" {
#   description = "Name of the EKS cluster"
#   type        = string
#   default     = "EKSCluster-ajay"
# }

# variable "environment" {
#   description = "Environment name for resource tagging"
#   type        = string
#   default     = "production"
# }

# # Local variables for common tags
# locals {
#   common_tags = {
#     Environment = var.environment
#     ManagedBy   = "terraform"
#     Cluster     = var.cluster_name
#   }
# }

# # Data sources
# data "aws_eks_cluster" "cluster" {
#   name = var.cluster_name
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = var.cluster_name
# }

# data "tls_certificate" "eks" {
#   url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
# }

# # Create OIDC Provider
# resource "aws_iam_openid_connect_provider" "eks" {
#   url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]

#   tags = local.common_tags
# }

# # Cluster Autoscaler IAM Role
# resource "aws_iam_role" "cluster_autoscaler" {
#   name = "${var.cluster_name}-autoscaler-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = aws_iam_openid_connect_provider.eks.arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
#         }
#       }
#     }]
#   })

#   tags = local.common_tags
# }

# # Cluster Autoscaler IAM Policy
# resource "aws_iam_policy" "cluster_autoscaler" {
#   name        = "${var.cluster_name}-autoscaler-policy"
#   description = "Policy for Cluster Autoscaler"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = [
#         "autoscaling:DescribeAutoScalingGroups",
#         "autoscaling:DescribeAutoScalingInstances",
#         "autoscaling:DescribeLaunchConfigurations",
#         "autoscaling:DescribeScalingActivities",
#         "autoscaling:DescribeTags",
#         "autoscaling:SetDesiredCapacity",
#         "autoscaling:TerminateInstanceInAutoScalingGroup",
#         "ec2:DescribeLaunchTemplateVersions"
#       ]
#       Resource = "*"
#     }]
#   })

#   tags = local.common_tags
# }

# resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
#   policy_arn = aws_iam_policy.cluster_autoscaler.arn
#   role       = aws_iam_role.cluster_autoscaler.name
# }

# # Load Balancer Controller IAM Role
# resource "aws_iam_role" "aws_lb_controller" {
#   name = "${var.cluster_name}-lb-controller-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = aws_iam_openid_connect_provider.eks.arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#         }
#       }
#     }]
#   })

#   tags = local.common_tags
# }

# # Load Balancer Controller IAM Policy
# resource "aws_iam_policy" "aws_lb_controller" {
#   name        = "${var.cluster_name}-lb-controller-policy"
#   description = "Policy for AWS Load Balancer Controller"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "iam:CreateServiceLinkedRole",
#           "ec2:DescribeAccountAttributes",
#           "ec2:DescribeAddresses",
#           "ec2:DescribeAvailabilityZones",
#           "ec2:DescribeInternetGateways",
#           "ec2:DescribeVpcs",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeInstances",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DescribeTags",
#           "ec2:GetCoipPoolUsage",
#           "ec2:DescribeCoipPools",
#           "ec2:*",
#           "elasticloadbalancing:DescribeLoadBalancers",
#           "elasticloadbalancing:DescribeLoadBalancerAttributes",
#           "elasticloadbalancing:DescribeListeners",
#           "elasticloadbalancing:DescribeListenerCertificates",
#           "elasticloadbalancing:DescribeSSLPolicies",
#           "elasticloadbalancing:DescribeRules",
#           "elasticloadbalancing:DescribeTargetGroups",
#           "elasticloadbalancing:DescribeTargetGroupAttributes",
#           "elasticloadbalancing:DescribeTargetHealth",
#           "elasticloadbalancing:*"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "cognito-idp:DescribeUserPoolClient",
#           "acm:ListCertificates",
#           "acm:DescribeCertificate",
#           "iam:ListServerCertificates",
#           "iam:GetServerCertificate",
#           "waf-regional:GetWebACL",
#           "waf-regional:GetWebACLForResource",
#           "waf-regional:AssociateWebACL",
#           "waf-regional:DisassociateWebACL",
#           "wafv2:GetWebACL",
#           "wafv2:GetWebACLForResource",
#           "wafv2:AssociateWebACL",
#           "wafv2:DisassociateWebACL",
#           "shield:GetSubscriptionState",
#           "shield:DescribeProtection",
#           "shield:CreateProtection",
#           "shield:DeleteProtection"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:AuthorizeSecurityGroupIngress",
#           "ec2:RevokeSecurityGroupIngress"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:CreateListener",
#           "elasticloadbalancing:DeleteListener",
#           "elasticloadbalancing:CreateRule",
#           "elasticloadbalancing:DeleteRule"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:AddTags",
#           "elasticloadbalancing:RemoveTags"
#         ]
#         Resource = [
#           "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
#           "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
#           "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:ModifyLoadBalancerAttributes",
#           "elasticloadbalancing:SetIpAddressType",
#           "elasticloadbalancing:SetSecurityGroups",
#           "elasticloadbalancing:SetSubnets",
#           "elasticloadbalancing:DeleteLoadBalancer",
#           "elasticloadbalancing:ModifyTargetGroup",
#           "elasticloadbalancing:ModifyTargetGroupAttributes",
#           "elasticloadbalancing:DeleteTargetGroup"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:RegisterTargets",
#           "elasticloadbalancing:DeregisterTargets"
#         ]
#         Resource = "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "elasticloadbalancing:SetWebAcl",
#           "elasticloadbalancing:ModifyListener",
#           "elasticloadbalancing:AddListenerCertificates",
#           "elasticloadbalancing:RemoveListenerCertificates",
#           "elasticloadbalancing:ModifyRule"
#         ]
#         Resource = "*"
#       }
#     ]
#   })

#   tags = local.common_tags
# }

# resource "aws_iam_role_policy_attachment" "aws_lb_controller" {
#   policy_arn = aws_iam_policy.aws_lb_controller.arn
#   role       = aws_iam_role.aws_lb_controller.name
# }

# # Kubernetes Service Accounts
# resource "kubernetes_service_account" "cluster_autoscaler" {
#   metadata {
#     name      = "cluster-autoscaler"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
#     }
#     labels = local.common_tags
#   }
# }

# resource "kubernetes_service_account" "aws_lb_controller" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
#     }
#     labels = local.common_tags
#   }
# }

# # Helm Releases
# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"
#   version    = "9.29.0"

#   values = [
#     yamlencode({
#       autoDiscovery = {
#         clusterName = var.cluster_name
#       }
#       awsRegion = var.aws_region
#       rbac = {
#         serviceAccount = {
#           create = false
#           name   = kubernetes_service_account.cluster_autoscaler.metadata[0].name
#         }
#       }
#       extraArgs = {
#         "balance-similar-node-groups"     = true
#         "skip-nodes-with-local-storage"   = false
#         "expander"                        = "least-waste"
#         "scale-down-delay-after-add"      = "10m"
#         "scale-down-unneeded-time"        = "10m"
#       }
#     })
#   ]

#   depends_on = [aws_iam_role_policy_attachment.cluster_autoscaler]
# }

# resource "helm_release" "aws_lb_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.6.0"

#   values = [
#     yamlencode({
#       region        = var.aws_region
#       clusterName   = var.cluster_name
#       serviceAccount = {
#         create = false
#         name   = kubernetes_service_account.aws_lb_controller.metadata[0].name
#       }
#       image = {
#         repository = "602401143452.dkr.ecr.${var.aws_region}.amazonaws.com/amazon/aws-load-balancer-controller"
#       }
#     })
#   ]

#   depends_on = [kubernetes_service_account.aws_lb_controller]
# }
