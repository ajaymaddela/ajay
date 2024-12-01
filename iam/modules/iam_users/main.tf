resource "aws_iam_user" "example" {
    name = "ajaykumar"
}
output "user_name" {
    value = aws_iam_user.example.name
  
}