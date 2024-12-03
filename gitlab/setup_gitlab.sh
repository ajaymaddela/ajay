#!/bin/bash

# Update the system and install necessary dependencies
yum update -y
yum install -y policycoreutils-python openssh-server openssh-clients perl curl

# Enable and start OpenSSH server daemon
systemctl enable sshd
systemctl start sshd

# Install Postfix for email notifications (optional)
yum install -y postfix
systemctl enable postfix
systemctl start postfix

# Add GitLab package repository
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash

