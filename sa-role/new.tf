provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33.1"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  eks_managed_node_group_defaults = {
    disk_size      = 10
    instance_types = ["t2.medium"]
    key_name = "dellajay"
  }
  eks_managed_node_groups = {
    blue = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t2.medium"]
      capacity_type  = "ON_DEMAND"
    }
    green = {
      min_size     = 0
      max_size     = 1
      desired_size = 0

      instance_types = ["t2.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }
}

output "oidc_provider_arn" {
    value = module.eks.oidc_provider_arn
}

# Conditionally create IRSA IAM roles only if iam_sa_roles is specified
module "iam_eks_roles" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  

  for_each = length(var.iam_sa_roles) > 0 ? var.iam_sa_roles : {}

  role_name = each.value.role_name

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["${each.value.namespace}:${each.value.service_account}"]
    }
  }

  role_policy_arns = each.value.policy_arns
  tags             = var.tags
}

# Conditionally create Kubernetes ServiceAccounts with IRSA annotation
resource "kubernetes_service_account" "eks_service_accounts" {
  for_each = length(var.iam_sa_roles) > 0 ? var.iam_sa_roles : {}

  metadata {
    name      = each.value.service_account
    namespace = each.value.namespace

    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_eks_roles[each.key].iam_role_arn
    }
  }

  depends_on = [module.eks]
}


variable "aws_region" {
  description = "AWS region where EKS is deployed"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for EKS worker nodes"
  type        = list(string)
}

variable "iam_sa_roles" {
  description = "IAM role mappings for service accounts"
  type = map(object({
    role_name       = string
    namespace       = string
    service_account = string
    policy_arns     = map(string)
  }))
  default = {} # If empty, IRSA resources will not be created
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}


