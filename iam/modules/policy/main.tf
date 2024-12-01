resource "aws_iam_policy" "policy" {
  name = "s3_access"
  policy = file("policies/iam_policy.json")
}
output "policy_arn" {
    value = aws_iam_policy.policy.arn
  
}