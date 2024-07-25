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
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.eks_vpc.id

  tags = {
    Name        = "eks-public-${count.index}"
    Environment = "dev"
  }
}

resource "aws_subnet" "eks_private" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index + 2}.0/24"
  vpc_id            = aws_vpc.eks_vpc.id

  tags = {
    Name        = "eks-private-${count.index}"
    Environment = "dev"
  }
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
resource "aws_eks_cluster" "EKSCluster" {
  name     = "EKSCluster"
  role_arn = aws_iam_role.EKSClusterRole.arn
  vpc_config {
    subnet_ids = aws_subnet.eks_private.*.id
    
    
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_eks_node_group" "NodeGroup1" {
  cluster_name    = aws_eks_cluster.EKSCluster.name
  node_group_name = "NodeGroup1"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = aws_subnet.eks_public.*.id
   instance_types = ["t2.micro"]
  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
    
    
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
resource "aws_alb" "eks_alb" {
  name            = "eks-alb"
  internal        = false
  security_groups = [aws_security_group.eks_alb_sg.id]
  subnets         = aws_subnet.eks_public.*.id

  tags = {
    Name        = "eks-alb"
    Environment = "dev"
  }
}

resource "aws_alb_target_group" "eks_alb_tg" {
  name     = "eks-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.eks_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "eks-alb-tg"
    Environment = "dev"
  }
}

resource "aws_alb_listener" "eks_alb_listener" {
  load_balancer_arn = aws_alb.eks_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.eks_alb_tg.arn
    type             = "forward"
  }
}

resource "aws_security_group" "eks_alb_sg" {
  name        = "eks-alb-sg"
  description = "Allow traffic to the ALB"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eks-alb-sg"
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
  count = 2
  subnet_id = aws_subnet.eks_public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "node_group" {
  name_prefix = "nodesg"
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}