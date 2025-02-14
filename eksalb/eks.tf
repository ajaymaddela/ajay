data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false


  vpc_id     = var.eks_vpc_id
  subnet_ids = var.eks_public_subnets

 # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["t2.medium"]
    key_name = "key"
  }

  eks_managed_node_groups = {
    blue = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

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


  # aws-auth configmap
  # manage_aws_auth_configmap = false

  tags = {
    Environment = "ajay"
    Terraform   = "true"
    Project = "ajay"
  }
}

output "oidc_provider_arn" {
    value = module.eks.oidc_provider_arn
  }

################################################################################
# Load Balancer Role
################################################################################

module "lb_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${var.env_name}_eks_lb"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

################################################################################
# Aws Load balancer Controller Service Account
################################################################################

resource "kubernetes_service_account" "service-account" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

################################################################################
# Install Load Balancer Controler With Helm
################################################################################

resource "helm_release" "lb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.service-account
  ]

  set {
    name  = "region"
    value = var.main-region
  }

  set {
    name  = "vpcId"
    value = var.eks_vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.main-region}.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
}