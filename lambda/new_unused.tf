provider "aws" {
  region = "us-east-1"
}

# IAM Role for Lambda (as previously defined)
resource "aws_iam_role" "lambda_execution_role" {
  name = "LambdaExecutionRoleWithLogging"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AWSLambdaBasicExecutionRole policy to Lambda role
resource "aws_iam_role_policy_attachment" "basic_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Custom IAM Policy for managing IAM keys
resource "aws_iam_policy" "lambda_policy" {
  name        = "DisableUnusedKeysPolicy"
  description = "Policy to allow Lambda to manage IAM keys"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "iam:ListUsers",
          "iam:ListAccessKeys",
          "iam:UpdateAccessKey",
          "iam:GetAccessKeyLastUsed"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Attach custom IAM policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "custom_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda Function (using previous example)
resource "aws_lambda_function" "disable_unused_keys" {
  filename         = "new_disable_unused_key.py"
  function_name    = "DisableUnusedKeys"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "disable_unused_keys.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("new_disable_unused_key.py")
  timeout = 300
}

# CloudWatch Rule to Trigger Lambda Every 20 Hours
resource "aws_cloudwatch_event_rule" "every_20_hours" {
  name                = "Every20HoursTrigger"
  
  schedule_expression = "cron(0/5 * * * ? *)"
  # Cron expression to trigger every 20 hours
}

# CloudWatch Event Target (Trigger Lambda)
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_20_hours.name
  target_id = "DisableUnusedKeysTarget"
  arn       = aws_lambda_function.disable_unused_keys.arn
}

# Lambda Permission to Allow CloudWatch Events to Invoke the Lambda
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.disable_unused_keys.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_20_hours.arn
}

data "aws_lambda_invocation" "list_users_output" {
  function_name = aws_lambda_function.disable_unused_keys.function_name
  input         = jsonencode({})
}

output "lambda_users_report" {
  value = jsondecode(data.aws_lambda_invocation.list_users_output.result).body
}