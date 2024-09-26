
# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Create private and public subnets
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet"
  }
}

# resource "aws_subnet" "public_subnet" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.0.0/24"
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "public-subnet"
#   }
# }

# # Create an Internet Gateway
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id
#   tags = {
#     Name = "main-igw"
#   }
# }

# # Create a Route Table for public subnets
# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
#   tags = {
#     Name = "public-route-table"
#   }
# }

# # Associate the public route table with the public subnet
# resource "aws_route_table_association" "public_subnet_association" {
#   subnet_id      = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.public_route_table.id
# }

# Create a security group
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ec2-sg"
  }
}

# Create an EC2 instance in the private subnet
resource "aws_instance" "example" {
  ami             = var.ami_id # Replace with a valid AMI ID for your region
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.private_subnet.id
  security_groups = [aws_security_group.ec2_sg.id]
  #   security_group = aws_security_group.ec2_sg.id
  tags = {
    Name = "example-instance"
  }
}

# Configure DNS resolution
resource "aws_vpc_dhcp_options" "main" {
  domain_name         = var.domain_name # Change this as per your DNS domain
  domain_name_servers = var.domain_name_servers_ip
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

# Create a Route Table for private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block         = var.ip_for_transit
    transit_gateway_id = aws_ec2_transit_gateway.example.id # Replace with your Transit Gateway ID
  }
  tags = {
    Name = "private-route-table"
  }
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_ec2_transit_gateway" "example" {
  description = "example"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
  subnet_ids         = [aws_subnet.private_subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.example.id
  vpc_id             = aws_vpc.main.id
}