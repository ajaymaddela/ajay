#!/bin/bash

# Function to display error and exit
display_error() {
    echo "Error: $1"
    exit 1
}

# Check if terraform command is available
if ! command -v terraform &> /dev/null; then
    display_error "Terraform command not found. Make sure Terraform is installed and added to PATH."
fi

# Change to your Terraform directory
TERRAFORM_DIR="deployment/terraform"
if [ ! -d "$TERRAFORM_DIR" ]; then
    display_error "Terraform directory not found: $TERRAFORM_DIR"
fi
cd "$TERRAFORM_DIR" || display_error "Failed to change to Terraform directory: $TERRAFORM_DIR"

# Initialize Terraform
terraform init || display_error "Failed to initialize Terraform"

# Execute Terraform plan
terraform plan -out=tfplan || display_error "Failed to create Terraform plan"

# Apply Terraform changes
terraform apply tfplan || display_error "Failed to apply Terraform changes"
