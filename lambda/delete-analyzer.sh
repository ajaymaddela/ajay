#!/bin/bash

# Get a list of all AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop through each region and delete IAM Access Analyzers
for region in $regions; do
  echo "Processing region: $region"

  # Fetch the analyzer name for the current region
  analyzer_name=$(aws accessanalyzer list-analyzers --region "$region" --query "analyzers[?type=='ACCOUNT'].name" --output text)

  if [ -n "$analyzer_name" ]; then
    # Delete the Access Analyzer
    echo "Deleting Access Analyzer: $analyzer_name in region: $region"
    aws accessanalyzer delete-analyzer --region "$region" --analyzer-name "$analyzer_name"
    echo "Access Analyzer deleted in region: $region."
  else
    echo "No Access Analyzer found in region: $region. Skipping."
  fi
done

echo "Access Analyzer deletion completed in all regions."
