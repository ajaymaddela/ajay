# resource "aws_config_conformance_pack" "bespin_custom" {
#   name = "BESPIN-Custom-Conformance-Pack"

#   input_parameter {
#     parameter_name = ""
#     parameter_value = ""
#   }
# }


# resource "aws_config_conformance_pack" "s3conformancepack" {
#   name = "s3conformancepack"

#   template_body = <<EOT
# AWSTemplateFormatVersion: '2010-09-09'
# Description: "S3 Security Compliance Conformance Pack"

# Resources:
#   S3BucketPublicReadProhibited:
#     Type: AWS::Config::ConfigRule
#     Properties:
#       ConfigRuleName: S3BucketPublicReadProhibited
#       Description: "Ensures S3 buckets do not allow public read access."
#       Source:
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_PUBLIC_READ_PROHIBITED
#       MaximumExecutionFrequency: Six_Hours

#   S3BucketPublicWriteProhibited:
#     Type: AWS::Config::ConfigRule
#     Properties:
#       ConfigRuleName: S3BucketPublicWriteProhibited
#       Description: "Ensures S3 buckets do not allow public write access."
#       Source:
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_PUBLIC_WRITE_PROHIBITED
#       MaximumExecutionFrequency: Six_Hours

#   S3BucketReplicationEnabled:
#     Type: AWS::Config::ConfigRule
#     Properties:
#       ConfigRuleName: S3BucketReplicationEnabled
#       Description: "Ensures S3 buckets have cross-region replication enabled."
#       Source:
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_REPLICATION_ENABLED

#   S3BucketSSLRequestsOnly:
#     Type: AWS::Config::ConfigRule
#     Properties:
#       ConfigRuleName: S3BucketSSLRequestsOnly
#       Description: "Ensures S3 buckets require SSL requests."
#       Source:
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_SSL_REQUESTS_ONLY

#   ServerSideEncryptionEnabled:
#     Type: AWS::Config::ConfigRule
#     Properties:
#       ConfigRuleName: ServerSideEncryptionEnabled
#       Description: "Ensures S3 buckets enforce server-side encryption."
#       Source:
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED

#   S3BucketLoggingEnabled:
#     Type: AWS::Config::ConfigRule
#     Properties:
#       ConfigRuleName: S3BucketLoggingEnabled
#       Description: "Ensures S3 buckets have logging enabled."
#       Source:
#         Owner: AWS
#         SourceIdentifier: S3_BUCKET_LOGGING_ENABLED
# EOT
# }


# variable "conformance_pack_name" {
#   description = "The name of the conformance pack"
#   type        = string
# }

# variable "yaml_file_path" {
#   description = "Path to the conformance pack YAML file"
#   type        = string
# }

# resource "aws_config_conformance_pack" "this" {
#   name         = var.conformance_pack_name
#   template_body = file(var.yaml_file_path)
# }


variable "conformance_pack_name" {
  description = "The name of the conformance pack"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket where YAML files are stored"
  type        = string
}

variable "yaml_file_name" {
  description = "The YAML file to use for the conformance pack"
  type        = string
}

resource "aws_config_conformance_pack" "this" {
  name          = var.conformance_pack_name
  template_s3_uri = "s3://${var.s3_bucket_name}/${var.yaml_file_name}"
}