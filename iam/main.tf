module "iam_user" {
    source = "./modules/iam_users"
  
}
module "iam_policy" {
    source = "./modules/policy"
    
  
}
module "iam_policy_attachment" {
    source = "./modules/policy_attachment"
    user_name = module.iam_user.user_name
    policy_arn = module.iam_policy.policy_arn
  
}

# arn:aws:iam::684206014294:policy/s3_access

# terraform import module.iam_user.aws_iam_user.example ajaykumar

# terraform import module.iam_policy.aws_iam_policy.policy arn:aws:iam::684206014294:policy/s3_access

# terraform import module.iam_policy_attachment.aws_iam_user_policy_attachment.attachment ajaykumar/arn:aws:iam::684206014294:policy/s3_access