provider "aws" {
  region = "us-east-1"
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

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKSClusterRole.name
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
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.eks_vpc.id

  tags = {
    Name        = "eks-public-${count.index}"
    Environment = "dev"
  }
}

resource "aws_subnet" "eks_private" {
  count             = 2
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  cidr_block        = "10.0.${count.index + 2}.0/24"
  vpc_id            = aws_vpc.eks_vpc.id

  tags = {
    Name        = "eks-private-${count.index}"
    Environment = "dev"
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
  count          = 2
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
  instance_types  = ["t2.micro"]
  
  ami_type = "AL2_x86_64"
  capacity_type = "ON_DEMAND"
  disk_size = "10"

  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_route_table_association.private
  ]
  
}

# resource "aws_launch_template" "eks_launch_template" {
#   name                 = "eks-launch-template"
  
#   # image_id             = "ami-0030945a5e6d38ef4" # Update this to the correct EKS AMI
#   vpc_security_group_ids = [aws_security_group.node_group.id]

#   # user_data = base64encode(<<-EOF
#   #      #!/bin/bash
#   #      /etc/eks/bootstrap.sh ${aws_eks_cluster.EKSCluster.name}
#   #     EOF
#   # )

#   lifecycle {
#     create_before_destroy = false
#   }
# }

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