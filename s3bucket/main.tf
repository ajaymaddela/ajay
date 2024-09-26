provider "aws" {
  region = "us-east-1"
}

data "aws_s3_bucket" "source_bucket" {
  bucket = "ajay-1234"
}

data "aws_s3_bucket" "destination_bucket" {
  bucket = "ajay-12345"
}

resource "aws_iam_role" "replication_role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "replication_policy" {
  name = "s3-replication-policy"
  role = aws_iam_role.replication_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          
        ]
        Resource = [
          "${data.aws_s3_bucket.source_bucket.arn}/*",
          data.aws_s3_bucket.source_bucket.arn,
          "${data.aws_s3_bucket.destination_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "source_bucket_replication" {
  bucket = data.aws_s3_bucket.source_bucket.id

  role = aws_iam_role.replication_role.arn

  rule {
    id     = "replication-rule"
    status = "Enabled"

    filter {
      prefix = ""  # Ensure the prefix is correct or remove this if not needed
    }

    destination {
      bucket        = data.aws_s3_bucket.destination_bucket.arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Enabled"  # Set to "Disabled" if you do not want to replicate delete markers
    }

  
  }
}

resource "aws_s3_bucket_policy" "source_bucket_policy" {
  bucket = data.aws_s3_bucket.source_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action   = "s3:GetObject"
        Resource = "${data.aws_s3_bucket.source_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action   = "s3:ReplicateObject"
        Resource = "${data.aws_s3_bucket.source_bucket.arn}/*"
      }
    ]
  })
}
