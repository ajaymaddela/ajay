#!/bin/bash

# Get a list of all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop through each region and enable IAM Access Analyzer
for region in $regions; do
  echo "Enabling Access Analyzer in region: $region"

  # Check if Access Analyzer already exists
  analyzer_name=$(aws accessanalyzer list-analyzers --region "$region" --query "analyzers[?type=='ACCOUNT'].name" --output text)

  if [ -z "$analyzer_name" ]; then
    # Create Access Analyzer if not already present
    aws accessanalyzer create-analyzer --region "$region" --analyzer-name "AccessAnalyzer-$region" --type ACCOUNT
    echo "Access Analyzer created in $region."
  else
    echo "Access Analyzer already exists in $region."
  fi
done
