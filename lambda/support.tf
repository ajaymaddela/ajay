# provider "aws" {
#   region = "us-east-1"  # Specify the region (can be any region)
# }

# resource "aws_iam_role" "awssupport_access_role" {
#   name               = "AWSSupportAccessRole"
#   assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
#   description        = "Role for AWS Support Access to manage incidents"
# }

# data "aws_iam_policy_document" "assume_role_policy" {
#   statement {
#     actions   = ["sts:AssumeRole"]
#     principals {
#       type        = "Service"
#       identifiers = ["support.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "awssupport_access_attachment" {
#   role       = aws_iam_role.awssupport_access_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
# }
