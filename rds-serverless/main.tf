provider "aws" {
}

resource "aws_db_subnet_group" "gitlab" {
  name       = "gitlab-group"
  subnet_ids = ["subnet-0345bf3ce1ed85658", "subnet-0cebee3eab95eeec5"]
}

resource "aws_rds_cluster" "gitlab" {
  cluster_identifier      = "gitlab-cluster"
  engine                 = "aurora-postgresql"
  engine_version         = "16.6"

  database_name          = "testdb"
  master_username        = "testing"
  engine_mode = "provisioned"
   serverlessv2_scaling_configuration {
    min_capacity = 1.0
    max_capacity = 4.0
  }
  master_password        = "PA%%w0rd*"
  vpc_security_group_ids = ["sg-03b93980a1f2002e1"]
  db_subnet_group_name   = aws_db_subnet_group.gitlab.name
  skip_final_snapshot = true
  iam_database_authentication_enabled = false
  apply_immediately      = true
}

resource "aws_rds_cluster_instance" "name" {
  cluster_identifier = aws_rds_cluster.gitlab.id
  identifier = "ajay"
  instance_class = "db.serverless"
  engine = aws_rds_cluster.gitlab.engine
  engine_version = aws_rds_cluster.gitlab.engine_version
}
output "rds_endpoint" {
  value = aws_rds_cluster.gitlab.endpoint
}