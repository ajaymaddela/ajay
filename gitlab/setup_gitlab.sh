#!/bin/bash

# Update the system and install necessary dependencies
yum update -y
yum install -y perl policycoreutils openssh-server openssh-clients  curl

# Enable and start OpenSSH server daemon
systemctl enable sshd
systemctl start sshd

# Install Postfix for email notifications (optional)
yum install -y postfix
systemctl enable postfix
systemctl start postfix

# Add GitLab package repository
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

public_ip=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
# 3.85.142.160
sudo EXTERNAL_URL="http://$public_ip" yum install -y gitlab-ee
