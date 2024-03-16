resource "aws_instance" "east" {
  ami           = var.aws_instance
  instance_type = var.instance_type
}
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
}
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_cidrs
  depends_on = [aws_vpc.vpc]
}
resource "aws_security_group" "allow_ssh" {
  vpc_id     = aws_vpc.vpc.id
  name       = "allowssh"
  depends_on = [aws_subnet.subnet]
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