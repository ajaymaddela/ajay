provider "aws" {
  region = "us-west-1"
}

# 1. Create an S3 Bucket
resource "aws_s3_bucket" "my_bucket" { 
  bucket = "newsecondone-s3-ajay"
}

# 2. Enable EventBridge Notifications for the S3 Bucket
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.my_bucket.id
  eventbridge = true
}

# 3. Create a CloudWatch Log Group for S3 Access Logs
resource "aws_cloudwatch_log_group" "s3_access_logs" {
  name              = "/aws/events/access-logs"
  retention_in_days = 90
}

# 4. Create an EventBridge Rule for S3 Access Logs
resource "aws_cloudwatch_event_rule" "s3_access_logs_rule" {
  name        = "s3-access-logs-rule"
  description = "Capture S3 access log events"
  event_pattern = jsonencode({
    "source": ["aws.s3"],
  })
}

# 7. EventBridge Target to Send Logs to CloudWatch Log Group
resource "aws_cloudwatch_event_target" "s3_access_logs_target" {
  rule      = aws_cloudwatch_event_rule.s3_access_logs_rule.name
  arn       = aws_cloudwatch_log_group.s3_access_logs.arn
  
}

# 2. IAM Role for Firehose
resource "aws_iam_role" "firehose_role" {
  name = "firehose-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : { "Service" : "firehose.amazonaws.com" },
      "Action" : "sts:AssumeRole"
    }]
  })
}

# 3. IAM Policy for Kinesis Firehose (FIXED)
resource "aws_iam_policy" "firehose_policy" {
  name   = "firehose-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["s3:PutObject", "s3:GetObject", "s3:ListBucket"],
        "Resource" : [
          "${aws_s3_bucket.firehose_backup_bucket.arn}",
          "${aws_s3_bucket.firehose_backup_bucket.arn}/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "firehose:PutRecordBatch"  # Critical addition
        ],
        "Resource" : "*"
      },
      {
        "Effect": "Allow",
        "Action": "lambda:InvokeFunction",
        "Resource": "${aws_lambda_function.process_logs_lambda.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_firehose_policy" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}


# 6. Create a CloudWatch Logs Subscription Filter to Kinesis Firehose
resource "aws_cloudwatch_log_subscription_filter" "logs_to_firehose" {
  name            = "s3-access-logs-subscription"
  log_group_name  = aws_cloudwatch_log_group.s3_access_logs.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.firehose_stream.arn
  role_arn = aws_iam_role.firehose_role.arn
}

# 1. Create an S3 Bucket for backup of Kinesis Firehose data
resource "aws_s3_bucket" "firehose_backup_bucket" {
  bucket = "firehose-backup-bucket-ajay"
} 

# Kinesis Firehose Delivery Stream with Lambda Processing
# resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
#   name        = "s3-access-logs-firehose"
#   destination = "splunk"

#   splunk_configuration {
     
#     hec_endpoint               = "http://3.92.32.234:8088/services/collector"
#     hec_token                  = "d618c52f-9542-4105-8524-41ea61cee070"
#     hec_acknowledgment_timeout = 600
#     retry_duration             = 300
#     s3_backup_mode             = "FailedEvents"

#    s3_configuration {
#      bucket_arn = aws_s3_bucket.firehose_backup_bucket.arn
#      role_arn = aws_iam_role.firehose_role.arn
#    }
#     cloudwatch_logging_options {
#       enabled         = true
#       log_group_name  = "/aws/kinesisfirehose/s3-access-logs"
#       log_stream_name = "delivery"
#     }
#     processing_configuration {
#       enabled = true

#       processors {
#         type = "Lambda"

#         parameters {
#           parameter_name  = "LambdaArn"
#           parameter_value = aws_lambda_function.process_logs_lambda.arn
#         }
#       }
#     }
#   }

# }

# Kinesis Firehose Delivery Stream (FIXED PROCESSING CONFIG)
resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  name        = "s3-access-logs-firehose"
  destination = "splunk"

  splunk_configuration {
    hec_endpoint               = "https://3.92.32.234:8088/services/collector"
    hec_token                  = "d618c52f-9542-4105-8524-41ea61cee070"
    hec_acknowledgment_timeout = 600
    retry_duration             = 300
    s3_backup_mode             = "FailedEventsOnly"
   

    s3_configuration {
      bucket_arn          = aws_s3_bucket.firehose_backup_bucket.arn
      role_arn            = aws_iam_role.firehose_role.arn
      buffering_size      = 5    # MB
      buffering_interval  = 300  # Seconds
      compression_format  = "GZIP"
    }

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "/aws/kinesisfirehose/s3-access-logs"
      log_stream_name = "delivery"
    }

    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          # Added version qualifier
          parameter_value = "${aws_lambda_function.process_logs_lambda.arn}:$LATEST"
        }

        parameters {
          parameter_name  = "RoleArn"
          parameter_value = aws_iam_role.lambda_role.arn
        }
      }
    }
  }
}

# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  })
}

# IAM Policy for Lambda Function
resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      # Permissions for CloudWatch Logs
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      },
      # Allow Lambda to be invoked by Firehose
      {
        "Effect": "Allow",
        "Action": "lambda:InvokeFunction",
        "Resource": "*"
      }
    ]
  })
}

# Attach IAM Policy to Role
resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# 5. Create Lambda Deployment Package
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "log_transformation.py"
  output_path = "lambda_function_payload.zip"
}

# 6. Lambda Function to Format Logs
resource "aws_lambda_function" "process_logs_lambda" {
  function_name = "process_logs_lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "log_transformation.lambda_handler"
  runtime       = "python3.12"
  filename      = data.archive_file.lambda_zip.output_path
  publish       = true

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  memory_size      = 512
  timeout          = 60
}



# Lambda Permission for Firehose
resource "aws_lambda_permission" "allow_firehose" {
  statement_id  = "AllowFirehoseInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_logs_lambda.arn
  principal     = "firehose.amazonaws.com"
}
