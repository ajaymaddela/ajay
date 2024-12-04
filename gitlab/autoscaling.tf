# Launch Template for EC2 instances
provider "aws" {
  region  = "us-east-1"  # Adjust your region if needed
  profile = "sandbox"    # Use the sandbox profile
}

data "local_file" "userdata_script" {
  filename = "metadata.sh"  # Path to your metadata.sh file
}
resource "aws_launch_template" "example" {
  name_prefix   = "example-"
  image_id      = "ami-0453ec754f44f9a4a"  # Replace with the correct AMI ID
  instance_type = "t2.large"
  key_name = "dell"

  # User Data script
  user_data = base64encode(data.local_file.userdata_script.content)  # Replace with your local file path

  

  # Optionally, you can define block device mappings, key pairs, etc.
}

# Auto Scaling Group configuration
resource "aws_autoscaling_group" "example" {
  desired_capacity     = 1  # Set the desired number of instances
  min_size             = 1  # Minimum number of instances
  max_size             = 3  # Maximum number of instances
  vpc_zone_identifier  = ["subnet-0df7c94227454cae9", "subnet-08dfb434d3fcbf19d"]  # Replace with your subnet IDs
  launch_template {
    id = aws_launch_template.example.id
    version              = "$Latest"
  }

  health_check_type          = "EC2"
  health_check_grace_period = 600
  force_delete              = true
  depends_on = [ aws_launch_template.example ]
}