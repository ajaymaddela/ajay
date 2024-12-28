# # main.tf

# provider "aws" {
#   region = "us-west-2" # Replace with your desired region
# }

# # 1. Define IAM Policy for API Access
# resource "aws_iam_policy" "api_access_policy" {
#   name        = "APIAccessPolicy"
#   description = "IAM policy to allow API access to specific AWS services"
#   policy      = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "s3:ListBucket",    # List S3 buckets
#           "s3:GetObject",     # Get objects from S3
#           "dynamodb:Query",   # Query DynamoDB tables
#         ],
#         Resource = [
#           "arn:aws:s3:::my-bucket-name",        # Specific S3 bucket
#           "arn:aws:s3:::my-bucket-name/*",      # Objects in the bucket
#           "arn:aws:dynamodb:us-west-2:123456789012:table/my-table" # DynamoDB table
#         ]
#       }
#     ]
#   })
# }

# # 2. Create IAM Role
# resource "aws_iam_role" "api_access_role" {
#   name = "APIAccessRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         },
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# # 3. Attach Policy to IAM Role
# resource "aws_iam_role_policy_attachment" "attach_api_access_policy" {
#   role       = aws_iam_role.api_access_role.name
#   policy_arn = aws_iam_policy.api_access_policy.arn
# }

# # 4. Create Instance Profile
# resource "aws_iam_instance_profile" "api_instance_profile" {
#   name = "APIInstanceProfile"
#   role = aws_iam_role.api_access_role.name
# }

# # 5. Create Security Group for EC2 Instance
# resource "aws_security_group" "ec2_security_group" {
#   name_prefix = "ec2-api-sg-"
#   description = "Allow SSH access"
#   vpc_id      = "vpc-xxxxxxxx" # Replace with your VPC ID

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # SSH access (adjust for security)
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # 6. Launch EC2 Instance with IAM Role
# resource "aws_instance" "api_access_instance" {
#   ami           = "ami-xxxxxxxx" # Replace with your desired AMI
#   instance_type = "t2.micro"     # Replace with your instance type
#   subnet_id     = "subnet-xxxxxxxx" # Replace with your subnet ID

#   iam_instance_profile = aws_iam_instance_profile.api_instance_profile.name
#   security_groups      = [aws_security_group.ec2_security_group.name]

#   tags = {
#     Name = "EC2WithAPIAccess"
#   }
# }

# # Output public IP and instance ID for reference
# output "ec2_instance_public_ip" {
#   value = aws_instance.api_access_instance.public_ip
# }

# output "ec2_instance_id" {
#   value = aws_instance.api_access_instance.id
# }
