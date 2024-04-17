module "ajay" {
  source = "./modules/dbinstance"

  aws_db_instance_class    = "db.t3.micro"
  allocated_storage_store  = 20
  db_name_name             = "ajay"
  engine_name              = "mysql"
  engine_version_ver       = "5.7"
  username_name            = "ajay"
  password_key             = "ajay12345"
  parameter_group_name_nsm = "default.mysql5.7"
  skip_final_snapshot_snap = true

}