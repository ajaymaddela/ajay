import boto3
import paramiko
import time
import os

# Initialize a Boto3 EC2 client using the 'sandbox' profile
session = boto3.Session(profile_name="sandbox", region_name="us-east-1")
ec2_client = session.client('ec2')

# Fetch the public IP from the environment variable
public_ip = os.getenv("PUBLIC_IP")

if not public_ip:
    print("Error: No public IP available.")
    exit(1)

# Print and log the instance public IP
print(f"Public IP: {public_ip}")

# Set up SSH connection using Paramiko
private_key_path = "/home/dell/dell.pem"  # Adjust the path to your private key
ssh_client = paramiko.SSHClient()
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh_client.connect(public_ip, username='ec2-user', key_filename=private_key_path)

# Run the command to install GitLab using the fetched public IP
command = f"sudo EXTERNAL_URL=http://{public_ip} yum install -y gitlab-ee"
stdin, stdout, stderr = ssh_client.exec_command(command)

# Wait for the command to complete and fetch the output
stdout_lines = stdout.readlines()
stderr_lines = stderr.readlines()

print("STDOUT:")
print("".join(stdout_lines))

print("STDERR:")
print("".join(stderr_lines))

# Close the SSH connection
ssh_client.close()


# to run this require pip boto3 paramiko
# sudo apt install python3.12-venv
#     python3 -m venv myenv
#    ls -al
#     source myenv/bin/activate
#    pip install boto3 paramiko