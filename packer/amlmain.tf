provider "aws" {
  region = "us-west-2" # Change to your desired region
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default = "ami-0027d02679c45aecc"
}

variable "instance_type" {
  description = "The type of instance to use for the launch template"
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type        = string
  default = "vpc-0d71ea84a877bdbac"
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the ASG"
  type        = list(string)
  default = [ "subnet-0044e5f38ebb2220b", "subnet-0bbf7448339d8cd41" ]
}



resource "aws_security_group" "efs_sg" {
  name_prefix = "example-efs-sg-"
  vpc_id      = var.vpc_id
}

resource "aws_efs_file_system" "example" {
  creation_token = "example-efs"
  performance_mode = "generalPurpose"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_efs_mount_target" "example" {
  file_system_id = aws_efs_file_system.example.id
  subnet_id      = var.subnet_ids[0]
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_security_group_rule" "efs_inbound" {
  type        = "ingress"
  from_port    = 2049
  to_port      = 2049
  protocol     = "tcp"
  security_group_id = aws_security_group.efs_sg.id
  cidr_blocks  = ["0.0.0.0/0"]
}


resource "aws_launch_template" "example" {
  name_prefix   = "example-lt-"
  image_id       = var.ami_id
  instance_type  = var.instance_type
  key_name = "jenkins-hpa"

   user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-efs-utils
              mkdir -p /mnt/efs
              sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-08f8a89c5a696a00f.efs.us-west-2.amazonaws.com:/ /mnt/efs
              echo "fs-08f8a89c5a696a00f.efs.us-west-2.amazonaws.com:/ /mnt/efs efs tls,_netdev" >> /etc/fstab
              EOF
  )
  
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [ aws_efs_file_system.example ]
}


resource "aws_security_group" "alb_sg" {
  name_prefix = "example-alb-sg-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true

  idle_timeout = 60
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.example.arn
      }
    }
  }
}

resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 29
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher = "200-499"
    
  }
  

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  vpc_zone_identifier = var.subnet_ids
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  target_group_arns = [ aws_lb_target_group.example.arn ]

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.example.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name                = "cpu-utilization-high"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 50
  alarm_description         = "Alarm when CPU exceeds 50%"
  alarm_actions             = [aws_autoscaling_policy.scale_out.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name                = "cpu-utilization-low"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 20
  alarm_description         = "Alarm when CPU is below 20%"
  alarm_actions             = [aws_autoscaling_policy.scale_in.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.example.name
  }
}