# # Providers for each region
# provider "aws" {
#   # Default provider (e.g., shared resources)
# }

# provider "aws" {
#   alias  = "usw1"
#   region = "us-west-1"
# }

# provider "aws" {
#   alias  = "usw2"
#   region = "us-west-2"
# }

# # Variables
# variable "org_external_access_analyzer_name1" {
#   description = "The base name of the organization external access analyzer."
#   type        = string
#   default     = "OrgAccessAnalyzerusw1"
# }

# # Variables
# variable "org_external_access_analyzer_name2" {
#   description = "The base name of the organization external access analyzer."
#   type        = string
#   default     = "OrgAccessAnalyzerusw2"
# }

# # External data source to fetch analyzers in us-west-1
# data "external" "usw1_analyzers" {
#   program = [
#     "bash", "-c", <<EOT
# analyzers=$(aws accessanalyzer list-analyzers --region us-west-1 --query "analyzers[*].name" --output text)
# echo "{\"analyzers\":\"$analyzers\"}"
# EOT
#   ]
# }

# # External data source to fetch analyzers in us-west-2
# data "external" "usw2_analyzers" {
#   program = [
#     "bash", "-c", <<EOT
# analyzers=$(aws accessanalyzer list-analyzers --region us-west-2 --query "analyzers[*].name" --output text)
# echo "{\"analyzers\":\"$analyzers\"}"
# EOT
#   ]
# }

# # Local variables to determine if an analyzer already exists
# locals {
#   existing_analyzer_usw1 = length(trimspace(data.external.usw1_analyzers.result.analyzers)) > 0
#   existing_analyzer_usw2 = length(trimspace(data.external.usw2_analyzers.result.analyzers)) > 0
# }

# # Create Access Analyzer in us-west-1 only if it doesn't exist
# resource "aws_accessanalyzer_analyzer" "usw1" {
#   provider      = aws.usw1
#   analyzer_name = var.org_external_access_analyzer_name1
#   type          = "ACCOUNT"

#   count = local.existing_analyzer_usw1 ? 0 : 1
 
# }

# # Create Access Analyzer in us-west-2 only if it doesn't exist
# resource "aws_accessanalyzer_analyzer" "usw2" {
#   provider      = aws.usw2
#   analyzer_name = var.org_external_access_analyzer_name2
#   type          = "ACCOUNT"

#   count = local.existing_analyzer_usw2 ? 0 : 1
  
# }
