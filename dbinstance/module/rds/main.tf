resource "aws_db_instance" "default" {
  
  allocated_storage    = var.allocated_storage
  db_name              = var.db_name
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  username             = var.username
  password             = var.password
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot  = var.skip_final_snapshot
  identifier = "snapshot"
}
resource "aws_iam_role" "fisirole" {
  name        = "fisi-role"
  description = "Example role for FIS experiment template"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      
      
      "Principal": {
        "Service": "fis.amazonaws.com"
        
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_policy" "fisipolicy" {
  name        = "fisi-policy"
  description = "Example policy for FIS experiment template"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "fis:StartExperiment",
        "fis:ListExperiments",
        "rds:FailoverDBCluster",
        "rds:RebootDBInstance",
        "rds-db:connect",
        "rds:AddRoleToDBCluster",
				"rds:AddRoleToDBInstance",
        
        "iam:CreateServiceLinkedRole",
        "iam:AttachRolePolicy",
        "rds-db:roleInIntegration",
        "rds:DescribeDBInstances",
        "rds:ModifyDBInstance",
        "rds:RebootDBInstance"
        
      ],
     
      "Resource": "*",
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Action": "iam:PassRole",
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "AWSRoleIntegration"
    }
    
  ]
}
EOF
}

resource "aws_iam_role" "rds_role" {
  name = "rds-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "rds.amazonaws.com"
      }
    }]
  })
}

# Attach a policy to the RDS role


resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.fisirole.name
  policy_arn = aws_iam_policy.fisipolicy.arn
}
resource "aws_db_instance_role_association" "example" {
  db_instance_identifier = aws_db_instance.default.identifier
  feature_name           = "s3Import"
  role_arn               = aws_iam_role.rds_role.arn
}
resource "aws_fis_experiment_template" "fistemplate" {
  description = "testing"
  role_arn    = aws_iam_role.fisirole.arn
  stop_condition {
    source = "none"
  }
  action {
    name      = "FailoverDBCluster"
    action_id = "aws:rds:failover-db-cluster"
    target {
      key   = "Clusters"
      value = "rds-tar"
    }
  }
  target {
   name = "rds-tar"
   resource_type = "aws:rds:cluster"
   selection_mode = "COUNT(1)"
   resource_tag {
     key = "env"
     value = "example"
   }
  }
  action {
    name      = "RebootDBInstance"
    action_id = "aws:rds:reboot-db-instances"
    target {
      key   = "DBInstances"
      value = "rds-target"
    }
  }
  target {
    name           = "rds-target"
    resource_type  = "aws:rds:db"
    selection_mode = "COUNT(1)"
    resource_arns = [ aws_db_instance.default.arn ]
    # resource_tag {
    #   key   = "env"
    #   value = "example"
    # }
  }
}