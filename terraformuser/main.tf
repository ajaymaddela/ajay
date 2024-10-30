module "ajay" {
  source = "./modules/ajay"

  instance_type = var.instance_type
  ami_id        = var.ami_id
  ami_name      = var.ami_name
  # account_ids   = var.account_ids

}