resource "aws_iam_user_policy_attachment" "attachment" {
    user = var.user_name
    policy_arn = var.policy_arn
  
}