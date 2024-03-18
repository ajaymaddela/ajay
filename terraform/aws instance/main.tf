resource "aws_instance" "east" {
  ami           = "ami-0d7a109bf30624c99"
  instance_type = var.instance_type
}
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
}
resource "aws_subnet" "subnets" {
  count      = length(var.subnet_names)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, count.index)
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