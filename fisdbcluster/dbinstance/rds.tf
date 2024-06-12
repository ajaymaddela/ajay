module "rds" {
  source = "./module/rds"

  cluster_identifier           = var.cluster_identifier
  engine                       = var.engine
  engine_mode                  = var.engine_mode
  master_username              = var.master_username
  master_password              = var.master_password
  skip_final_snapshot          = var.skip_final_snapshot
  availability_zones           = var.availability_zones
  cluster_instance_identifier1 = var.cluster_instance_identifier1
  cluster_instance_identifier2 = var.cluster_instance_identifier2
  instance_class               = var.instance_class
  fis_role_name                = var.fis_role_name
  fis_policy_name              = var.fis_policy_name
  rds_role_name                = var.rds_role_name
  feature_name                 = var.feature_name

}