resource "aws_rds_cluster" "aurora_cluster" {

  cluster_identifier  = var.cluster_identifier
  engine              = var.engine
  engine_mode         = var.engine_mode
  master_username     = var.master_username
  master_password     = var.master_password
  skip_final_snapshot = var.skip_final_snapshot
  availability_zones  = var.availability_zones
}

resource "aws_rds_cluster_instance" "aurora_instance_1" {
  identifier         = var.cluster_instance_identifier1
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine             = var.engine
}

resource "aws_rds_cluster_instance" "aurora_instance_2" {
  identifier         = var.cluster_instance_identifier2
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.instance_class
  engine             = var.engine
}






resource "aws_iam_role" "fisrole" {
  name               = var.fis_role_name
  description        = "Role for FIS experiment template"
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
resource "aws_iam_policy" "fispolicy" {
  name        = var.fis_policy_name
  description = "Policy for FIS experiment template"
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
  name = var.rds_role_name
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
  role       = aws_iam_role.fisrole.name
  policy_arn = aws_iam_policy.fispolicy.arn
}
resource "aws_rds_cluster_role_association" "example" {
  db_cluster_identifier = aws_rds_cluster.aurora_cluster.cluster_identifier
  feature_name          = var.feature_name
  role_arn              = aws_iam_role.rds_role.arn
}

resource "aws_fis_experiment_template" "fistemplate" {
  description = "testing"
  role_arn    = aws_iam_role.fisrole.arn
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
    name           = "rds-tar"
    resource_type  = "aws:rds:cluster"
    selection_mode = "COUNT(1)"
    resource_arns  = [aws_rds_cluster.aurora_cluster.arn]
    # resource_tag {
    #   key   = "env"
    #   value = "example"
    # }
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
    resource_arns  = [aws_rds_cluster_instance.aurora_instance_1.arn, aws_rds_cluster_instance.aurora_instance_2.arn]
    # resource_tag {
    #   key   = "env"
    #   value = "example"
    # }
  }
}