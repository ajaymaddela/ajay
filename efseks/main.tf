resource "aws_efs_file_system" "efs" {
  creation_token = "eks-efs"
  performance_mode = "generalPurpose"
  tags = {
    Name = "EKS-EFS"
  }
}

module "efs_csi_irsa" {
  source = "../../modules/iam-role-for-service-accounts-eks"

  role_name             = "efs-csi"
  attach_efs_csi_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = local.tags
}


resource "aws_eks_addon" "efs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-efs-csi-driver"
  addon_version            = "v1.9.1-eksbuild.1" # Check available version in AWS EKS documentation
  service_account_role_arn = module.efs_csi_irsa.iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
}

# apiVersion: storage.k8s.io/v1
# kind: StorageClass
# metadata:
#   name: efs-sc
# provisioner: efs.csi.aws.com


# apiVersion: v1
# kind: PersistentVolume
# metadata:
#   name: efs-pv
# spec:
#   capacity:
#     storage: 5Gi
#   accessModes:
#     - ReadWriteMany
#   persistentVolumeReclaimPolicy: Retain
#   storageClassName: efs-sc
#   csi:
#     driver: efs.csi.aws.com
#     volumeHandle: <your-efs-id>  # Replace with the actual EFS FileSystem ID


# ---
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: efs-pvc
# spec:
#   accessModes:
#     - ReadWriteMany
#   storageClassName: efs-sc
#   resources:
#     requests:
#       storage: 5Gi
