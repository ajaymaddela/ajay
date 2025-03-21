module "iam_eks_role" {
  source = "../../terraform_module/terraform-aws-iam/modules/iam-role-for-service-accounts-eks"

  role_name = "my-app"

  role_policy_arns = {
    policy = "arn:aws:iam::012345678901:policy/myapp"
  }

  oidc_providers = {
    one = {
      provider_arn               = "arn:aws:iam::012345678901:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/5C54DDF35ER19312844C7333374CC09D"
      namespace_service_accounts = ["default:my-app-staging", "canary:my-app-staging"]
    }
    two = {
      provider_arn               = "arn:aws:iam::012345678901:oidc-provider/oidc.eks.ap-southeast-1.amazonaws.com/id/5C54DDF35ER54476848E7333374FF09G"
      namespace_service_accounts = ["default:my-app-staging"]
    }
  }
}
