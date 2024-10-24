resource "aws_instance" "ecs_instance" {
  ami           = var.ami_id # Replace with a valid base AMI
  instance_type = var.instance_type

  user_data = data.template_file.user_data.rendered

  tags = {
    Name = "Docker Instance"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/../../user_data.tpl")
}

resource "aws_ami_from_instance" "docker_ami" {
  source_instance_id = aws_instance.ecs_instance.id
  name               = var.ami_name
}

resource "aws_ami_launch_permission" "example" {
  image_id   = aws_ami_from_instance.docker_ami.id
  account_id = var.account_ids # Replace with actual AWS account IDs
}

output "instance_id" {
  value = aws_instance.ecs_instance.id
}

output "ami_id" {
  value = aws_ami_from_instance.docker_ami.id
}
