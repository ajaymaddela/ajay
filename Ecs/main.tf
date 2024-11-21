resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 1)
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

resource "aws_launch_template" "ecs_instances" {
  name_prefix      = "ecs-ec2"
  instance_type    = var.instance_type
  key_name         = var.key_name
  image_id = "ami-0f400f5b90fa74704"
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_profile.name
  }
  user_data = base64encode(templatefile("ecs_user_data.sh", {
    cluster_name = aws_ecs_cluster.cluster.name
  }))
  
  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = aws_subnet.public.id
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  launch_template {
    id      = aws_launch_template.ecs_instances.id
    version = "$Latest"
  }

  min_size         = 1
  max_size         = 2
  desired_capacity = 1
  vpc_zone_identifier = [
    aws_subnet.public.id
  ]
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_instance_policy" {
    name = "Role"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  roles      = [aws_iam_role.ecs_instance_role.name]
}

resource "aws_iam_instance_profile" "ecs_profile" {
  name = "ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_ecs_task_definition" "httpd" {
  family                   = "httpd-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name        = "httpd"
      image       = "httpd:latest"
      cpu         = 256
      memory      = 512
      essential   = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "httpd_service" {
  name            = "httpd-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.httpd.arn
  launch_type     = "EC2"
  desired_count   = 1
}
