vpc_cidr               = "10.0.0.0/16"
private_subnet_cidr    = "10.0.1.0/24"
availability_zone      = "us-east-1a"
ami_id                 = "ami-0182f373e66f89c85"
instance_type          = "t2.micro"
domain_name            = "ec2.internal"
domain_name_servers_ip = ["10.2.3.1", "10.2.4.2"]
ip_for_transit         = "0.0.0.0/0"