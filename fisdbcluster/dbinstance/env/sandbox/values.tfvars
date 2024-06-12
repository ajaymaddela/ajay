cluster_identifier           = "chaostest"
engine                       = "aurora-postgresql"
engine_mode                  = "provisioned"
master_username              = "appsoc"
master_password              = "PA%%w0rd*"
skip_final_snapshot          = true
availability_zones           = ["us-east-1a", "us-east-1b"]
cluster_instance_identifier1 = "chaostest-instance-1"
cluster_instance_identifier2 = "chaostest-instance-1-us-east-1a"
instance_class               = "db.t3.medium"
fis_role_name                = "fis-role"
fis_policy_name              = "fis-policy"
rds_role_name                = "rds-role"
feature_name                 = "s3Import"






