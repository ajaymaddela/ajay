resource "aws_db_instance" "ajay" {
    instance_class = var.aws_db_instance_class
    allocated_storage = var.allocated_storage_store
    db_name = var.db_name_name
    engine = var.engine_name
    engine_version = var.engine_version_ver
    username = var.username_name
    password = var.password_key
    parameter_group_name = var.parameter_group_name_nsm
    skip_final_snapshot = var.skip_final_snapshot_snap
  
}
# resource "aws_instance" "sri" {
#   ami = var.ami_id
#   instance_type = var.instance_type_type
#   user_data = 

# }