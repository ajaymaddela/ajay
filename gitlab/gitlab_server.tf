

# # EC2 Instance resource
# resource "aws_instance" "gitlab_instance" {
#   ami           = "ami-0453ec754f44f9a4a"  # Update this with your AMI
#   instance_type = "t2.large"
#   key_name      = "dell"
#   user_data     = file("setup_gitlab.sh")  # Path to your shell script
#   subnet_id     = "subnet-0df7c94227454cae9"  # Update with your subnet ID
#   tags = {
#     Name = "GitLab-Instance"
#   }

#   vpc_security_group_ids = ["sg-05fc660aab8442bff"]  # Update with your security group

#   associate_public_ip_address = true  # Ensure the instance has a public IP
# }

# # Ensure the instance has a public IP before proceeding
# resource "time_sleep" "wait_for_ip" {
#   depends_on = [aws_instance.gitlab_instance]
#   create_duration = "60s"  # Wait for 60 seconds (adjust as needed)
# }

# # Null resource to install GitLab using the public IP
# resource "null_resource" "gitlab_install" {
#   depends_on = [time_sleep.wait_for_ip]  # Ensure we wait for the public IP

#   provisioner "local-exec" {
#     command = "python3 install_gitlab.py"
#        environment = {
#       PUBLIC_IP = aws_instance.gitlab_instance.public_ip
#     }
#   }

#   triggers = {
#     instance_id = aws_instance.gitlab_instance.id
#   }
# }

# # Output the public IP of the instance
# output "instance_public_ip" {
#   value = aws_instance.gitlab_instance.public_ip
# }
