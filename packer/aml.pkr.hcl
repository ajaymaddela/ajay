packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

packer {
  required_version = ">= 1.8.0"
}

# Define the builders
source "amazon-ebs" "amazon_linux" {
  ami_name      = "amazon-linux-jenkins-ansible"
  instance_type = "t2.micro"
  region        = "us-west-2"

  source_ami     = "ami-074be47313f84fa38"  # Replace with your specified AMI ID
  ssh_username   = "ec2-user"
  ami_description = "Amazon Linux with Jenkins, AWS CLI, and Ansible"
  tags = {
    Name = "amazon-linux-jenkins-ansible"
  }
  
  # Network configuration
  vpc_id              = "vpc-0d71ea84a877bdbac"            # Replace with your VPC ID
  subnet_id           = "subnet-0044e5f38ebb2220b"         # Replace with your Subnet ID
  associate_public_ip_address = true  # Set to true if you need a public IP address

  # Optionally, you can specify a key pair if you need SSH access to the instance
  # key_name = "your-key-pair"
}

# Define the provisioners

build {
  sources = ["source.amazon-ebs.amazon_linux"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y java-17-amazon-corretto",  # Install Amazon Corretto 17 (Java 17)
      # Import Jenkins GPG Key
      "sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key",
      # Add Jenkins repository and install Jenkins
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo",
      "sudo yum install -y jenkins",
      "sudo yum install -y ansible",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins"
    ]
  }
}