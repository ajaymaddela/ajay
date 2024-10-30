#!/bin/bash
# Install Docker
yum update -y
yum install -y docker
service docker start
systemctl start docker
systemctl status docker
systemctl enable docker
usermod -aG docker ec2-user
