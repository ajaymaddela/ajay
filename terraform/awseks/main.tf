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

resource "aws_iam_role_policy_attachment" "admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.NodeGroupRole.name
}


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
  count                   = 1
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
      volume_size = 20
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

provider "kubernetes" {
  host                   = aws_eks_cluster.EKSCluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.EKSCluster.certificate_authority.0.data)
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.EKSCluster.endpoint
    token                  = data.aws_eks_cluster_auth.eks.token
    cluster_ca_certificate = base64decode(aws_eks_cluster.EKSCluster.certificate_authority.0.data)
  }
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.EKSCluster.name
}




# resource "helm_release" "lb" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   depends_on = [
#     aws_eks_cluster.EKSCluster
#   ]

#   set {
#     name  = "region"
#     value = "us-west-1"
#   }

#   set {
#     name  = "vpcId"
#     value = aws_vpc.eks_vpc.id
#   }

#   set {
#     name  = "image.repository"
#     value = "602401143452.dkr.ecr.us-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.EKSCluster.name
#   }
  
# }