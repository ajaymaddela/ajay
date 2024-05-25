resource "aws_instance" "east" {
  ami           = "ami-0d7a109bf30624c99"
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnets[0].id
}
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
}
resource "aws_subnet" "subnets" {
  count      = length(var.subnet_names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  depends_on = [aws_vpc.vpc]
}
resource "aws_security_group" "allow_ssh" {
  vpc_id     = aws_vpc.vpc.id
  name       = "allowssh"
  depends_on = [aws_subnet.subnets]
}
resource "aws_security_group_rule" "tcp" {
  type              = "ingress"
  to_port           = 65000
  from_port         = 0
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.allow_ssh.id
  depends_on        = [aws_security_group.allow_ssh]

}
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = aws_subnet.subnets[*].id

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "default" {
  allocated_storage = 10
  db_name           = "postgres"
  engine            = "postgres"
  engine_version    = "14"
  instance_class    = "db.t3.micro"
  username          = "foo"
  password          = "foobarbaz"
  # parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.default.name
}


resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "example-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.subnet_names)
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.public.id
}
