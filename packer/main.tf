provider "aws" {
  region = "us-east-1" # Change as needed
}

# Create a security group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name_prefix = "jenkins-sg-"
  vpc_id = "vpc-0ea636f8cc198e09b"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Change to more restrictive CIDR in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a launch template
resource "aws_launch_template" "jenkins_template" {
  name_prefix   = "jenkins-template-"
  image_id      = "ami-049446b29a15e6915" # Replace with your AMI ID
  instance_type = "t2.medium" # Change as necessary
  vpc_security_group_ids = [ aws_security_group.jenkins_sg.id ]
  

 user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo systemctl start jenkins
              EOF
  )
  lifecycle {
    create_before_destroy = true
  }
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "jenkins_asg" {
  name = "terraformasg"
  launch_template {
    id      = aws_launch_template.jenkins_template.id
    version = "$Latest"
  }

  min_size     = 1
  max_size     = 5
  desired_capacity = 1
  vpc_zone_identifier = ["subnet-0dbf590095292076c", "subnet-083e2a34e4bd53070"] # Replace with your subnet ID
  
 tag {
   key = "name"
   value = "jenkins"
   propagate_at_launch = true
 }

  health_check_type          = "EC2"
  health_check_grace_period  = 300
  wait_for_capacity_timeout     = "0"
}

# Create an Application Load Balancer
resource "aws_lb" "jenkins_lb" {
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jenkins_sg.id]
  subnets            = ["subnet-0dbf590095292076c", "subnet-083e2a34e4bd53070"] # Replace with your subnet IDs

  enable_deletion_protection = false
  
}

# Create a target group for the ALB
resource "aws_lb_target_group" "jenkins_tg" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "vpc-0ea636f8cc198e09b" # Replace with your VPC ID

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

# Attach the target group to the ALB
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.jenkins_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_tg.arn
  }
}

# Create a scaling policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment      = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment      = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.jenkins_asg.name
}
