provider "aws" {
  region = "us-east-1"
}

resource "aws_route53_zone" "main" {
  name = "ajaymaddela.online"
  vpc {
    vpc_region = "us-east-1"
    vpc_id = "vpc-03e21b227540fc0ac"
  }
}

resource "aws_route53_record" "dev-ns" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "ajju.ajaymaddela.online"
  type    = "A"
  ttl     = "300"
  records = ["192.0.0.1"]
}

resource "aws_route53_record" "dev" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "ajji.ajaymaddela.online"
  type    = "CNAME"
  ttl     = "300"
  records = ["ajju.ajaymaddela.online"]
}