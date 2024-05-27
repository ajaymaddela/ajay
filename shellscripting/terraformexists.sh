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

# Check if resource group already exists
exists=$(terraform show -json | jq '.values.root_module.resources[] | select(.type == "azurerm_resource_group") | .values.name' | tr -d '"')

# If resource group exists, destroy it
if [ -n "$exists" ]; then
    echo "Resource group already exists. Destroying..."
    terraform destroy -auto-approve || display_error "Failed to destroy Terraform resources"
fi

# Apply Terraform changes
terraform apply -auto-approve || display_error "Failed to apply Terraform changes"
