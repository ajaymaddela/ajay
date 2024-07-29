packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "learn-packer-jenkins-setup"
  instance_type = "t2.micro"
  region        = "us-east-1"
  
  # Use an existing AMI ID directly
  source_ami     = "ami-04a81a99f5ec58529"  # Replace with your AMI ID

  # Specify VPC and subnet IDs
  vpc_id         = "vpc-0ea636f8cc198e09b"  # Replace with your VPC ID
  subnet_id      = "subnet-0dbf590095292076c"  # Replace with your Subnet ID
  
  ssh_username   = "ubuntu"
}

build {
  name    = "learn-packer-jenkins-setup"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  
  provisioner "shell" {
    inline = [
      # Update package lists and install basic packages
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt-get update -y && sudo apt-get install dialog apt-utils -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y openjdk-17-jdk git", # Java 17

      # Install Jenkins
      "sudo wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -",
      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
      "sudo apt-get update -y",
      "sudo apt-get install -y jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",

      # Install Azure CLI
      "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash",

      # Install AWS CLI
      "sudo apt-get install -y awscli",

      # Install Ansible
      "sudo apt-get install -y ansible",

      # Install Packer
      "sudo wget https://releases.hashicorp.com/packer/1.11.1/packer_1.11.1_linux_amd64.zip",
      "unzip packer_1.11.1_linux_amd64.zip",
      "sudo mv packer /usr/local/bin/",
      "rm packer_1.11.1_linux_amd64.zip"
    ]
  }
}
