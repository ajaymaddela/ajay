# Provider configuration with dynamic region
provider "aws" {
  
}
provider "aws" {
  alias = "regional"
  region = var.target_region
}

# Variable for target region
variable "target_region" {
  description = "The region where the Access Analyzer should be created."
  type        = string
}

# Variable for analyzer name
variable "analyzer_name" {
  description = "The name of the organization external access analyzer."
  type        = string
}

# External data source to check if analyzer already exists
data "external" "analyzers" {
  program = [
    "bash", "-c", <<EOT
analyzers=$(aws accessanalyzer list-analyzers --region ${var.target_region} --query "analyzers[*].name" --output text)
echo "{\"analyzers\":\"$analyzers\"}"
EOT
  ]
}

# Local variable to check if the analyzer already exists
locals {
  existing_analyzer = length(trimspace(data.external.analyzers.result.analyzers)) > 0
}

# Create Access Analyzer only if it doesn't exist
resource "aws_accessanalyzer_analyzer" "analyzer" {
  analyzer_name = var.analyzer_name
  type          = "ACCOUNT"
  provider = aws.regional
  count = local.existing_analyzer ? 0 : 1
}
