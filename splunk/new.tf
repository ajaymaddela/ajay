provider "aws" {
  region = "us-west-1"
}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "Bucket" {
  bucket = "exam-bucket-nice"
}

resource "aws_s3_bucket_policy" "BucketPolicy" {
  bucket = aws_s3_bucket.Bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudTrailLogs"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.Bucket.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid       = "AllowCloudTrailBucketList"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::${aws_s3_bucket.Bucket.id}"
      }
    ]
  })
}

# Create a CloudWatch Logs group
resource "aws_cloudwatch_log_group" "TrailLogs" {
  name = "/aws/cloudtrail/S3DataEventsTrail"
  retention_in_days = 90
}

# IAM role for CloudTrail to publish to CloudWatch Logs
resource "aws_iam_role" "CloudTrailRole" {
  name = "CloudTrailRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy to allow CloudTrail to publish logs to CloudWatch
resource "aws_iam_role_policy" "CloudTrailPolicy" {
  role = aws_iam_role.CloudTrailRole.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.TrailLogs.arn}:*"
      }
    ]
  })
}

resource "aws_cloudtrail" "example" {
  name                       = "testing-s3"
  s3_bucket_name             = aws_s3_bucket.Bucket.id
#   s3_key_prefix              = "cloudtrail"
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.TrailLogs.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.CloudTrailRole.arn
  is_multi_region_trail      = true
  enable_logging             = true

  event_selector {
    read_write_type = "All"
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
    include_management_events = false
  }

  # Ensure CloudWatch Log Group is created first
  
}


# CloudWatch Event Rule to Trigger Lambda on S3 Data Events from CloudTrail
resource "aws_cloudwatch_event_rule" "CloudTrailEventRule" {
  name        = "CloudTrailEventRule"
  description = "Trigger Lambda on S3 data events logged by CloudTrail"
  event_pattern = jsonencode({
    source = ["aws.cloudtrail"],
    "detail-type" = ["AWS API Call via CloudTrail"],
    detail = {
      eventSource = ["s3.amazonaws.com"],
      eventName   = [
        "PutObject",
        "GetObject",
        "DeleteObject",
        "ListBucket"
      ]
    }
  })
}


resource "aws_cloudwatch_log_subscription_filter" "test_lambdafunction_logfilter" {
  name            = "test_lambdafunction_logfilter"
  role_arn        = aws_iam_role.CloudTrailRole.arn # to role to put cloudwatch logs to kinesis
  log_group_name  = "/aws/lambda/example_lambda_name"
  filter_pattern  = "logtype test"
  destination_arn = aws_kinesis_firehose_delivery_stream.Firehose.arn
  distribution    = "Random"
}

# Kinesis Firehose to Splunk
resource "aws_kinesis_firehose_delivery_stream" "Firehose" {
  name        = "FormattedLogsToSplunk"
  destination = "splunk"

  splunk_configuration {
    hec_endpoint       = "https://splunk.example.com:8088"
    hec_token          = "YOUR_SPLUNK_HEC_TOKEN"
    hec_acknowledgment_timeout = 300
    retry_duration = 300
    s3_backup_mode = "FailedEventsOnly"
    s3_configuration {
      role_arn = aws_iam_role.CloudTrailRole.arn
      bucket_arn = aws_s3_bucket.Bucket.arn
      buffering_interval = 300
      buffering_size = 5
      compression_format = "GZIP"
    }
  }
}