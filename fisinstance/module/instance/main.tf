resource "aws_placement_group" "test" {
  name     = "test"
  strategy = "cluster"
}

# Launch Template Resource
resource "aws_launch_template" "my_launch_template" {
  name = "my-launch-template"
  description = "My Launch Template"
  image_id = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"

#   vpc_security_group_ids = [module.private_sg.security_group_id]
#   key_name = var.instance_keypair  
#   user_data = filebase64("${path.module}/app1-install.sh")
  ebs_optimized = true
  #default_version = 1
  update_default_version = true
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 10 
      #volume_size = 20 # LT Update Testing - Version 2 of LT      
      delete_on_termination = true
      volume_type = "gp2" # default is gp2
     }
  }
  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "myasg"
    }
  }
}
resource "aws_autoscaling_group" "example" {
  name     = "foobar"
  max_size = 0
  min_size = 0
  # target_group_arns = aws_instance.ec2_instance.arn
#   launch_configuration = aws_launch_configuration.as_conf.name
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  launch_template {
    id = aws_launch_template.my_launch_template.id
  }
}
resource "aws_instance" "ec2_instance" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_iam_role" "fisrole_ec2" {
  name        = "fisrole"
  description = "Role for FIS experiment template for EC2 instances"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "fis.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_policy" "fispolicy_ec2" {
  name        = "fispolicy"
  description = "Policy for FIS experiment template for EC2 instances"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "fis:StartExperiment",
        "fis:ListExperiments",
        "ec2:RebootInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances",
        "ec2:ModifyInstanceAttribute",
        "ec2:CreateTags",
        "ec2:InjectApiError"
      ],
      Resource = "*",
      Effect   = "Allow"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "fisrole_attachment_ec2" {
  role       = aws_iam_role.fisrole_ec2.name
  policy_arn = aws_iam_policy.fispolicy_ec2.arn
}
resource "aws_fis_experiment_template" "fistemplate_ec2" {
  description = "Testing FIS on EC2 instances"
  role_arn    = aws_iam_role.fisrole_ec2.arn
  stop_condition {
    source = "none"
  }
  action {
    name      = "ApiInsufficientInstanceCapacityError"
    action_id = "aws:ec2:api-insufficient-instance-capacity-error"
    target {
      key   = "Roles"
      value = "iamrole"
    }
    parameter {
      key = "duration"
      value = "PT1M"
    }
    parameter {
      key = "availabilityZoneIdentifiers"
      value = "us-east-1a"
    }
    parameter {
      key = "percentage"
      value = "50"
    }
    # target {
    #   key   = "Instances"
    #   value = "ec2-target"
    # }
  }
  action {
    name      = "AsgInsufficientInstanceCapacityError"
    action_id = "aws:ec2:asg-insufficient-instance-capacity-error"
    target {
      key   = "AutoScalingGroups"
      value = "asg-target"
    }
    parameter {
      key = "duration"
      value = "PT1M"
    }
    parameter {
      key = "availabilityZoneIdentifiers"
      value = "us-east-1a"
    }
    
  }
  action {
    name      = "RebootInstances"
    action_id = "aws:ec2:reboot-instances"
    target {
      key   = "Instances"
      value = "ec2-target"
    }
    # target {
    #   key   = "AutoScalingGroups"
    #   value = "asg-target"
    # }

  }
  action {
    name      = "AutoScalingGroups"
    action_id = "aws:ec2:reboot-instances"
    #  target {
    #   key   = "Instances"
    #   value = "ec2-target"
    # }
    target {
      key   = "AutoScalingGroups"
      value = "asg-target"
    }
  }
  action {
    name      = "StopInstances"
    action_id = "aws:ec2:stop-instances"
    target {
      key   = "Instances"
      value = "ec2-target"
    }
  }
  action {
    name      = "AutoScalingGroups"
    action_id = "aws:ec2:stop-instances"
    # target {
    #   key   = "AutoScalingGroups"
    #   value = "asg-target"
    # }
     target {
      key   = "Instances"
      value = "ec2-target"
    }
  }
  action {
    name      = "TerminateInstances"
    action_id = "aws:ec2:terminate-instances"
    target {
      key   = "Instances"
      value = "ec2-target"
    }
    # target {
    #   key   = "AutoScalingGroups"
    #   value = "asg-target"


    # }
  }
  target {
    name           = "ec2-target"
    resource_type  = "aws:ec2:instance"
    selection_mode = "COUNT(1)"
    resource_arns  = [aws_instance.ec2_instance.arn]
  }
  target {
    name           = "asg-target"
    resource_type  = "aws:ec2:autoscaling-group"
    selection_mode = "COUNT(1)"
    resource_arns  = [aws_autoscaling_group.example.arn]
  }
  target {
    name = "iamrole"
    selection_mode = "COUNT(1)"
    resource_type = "aws:iam:role"
    resource_arns = [ aws_iam_role.fisrole_ec2.arn ]
  }
  depends_on = [ aws_autoscaling_group.example ]
  
}