## Create a eks cluster

```
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: ajay-cluster
  region: us-east-1

nodeGroups:
  - name: ng-1
    instanceType: t2.medium
    desiredCapacity: 1
    volumeSize: 8
```
## Use the below cli command to get oidc of the cluster

```
aws eks describe-cluster --name basic-cluster --query "cluster.identity.oidc.issuer" --output text
```
## You will get oidc provider of the cluster.

```
https://oidc.eks.us-east-1.amazonaws.com/id/0DEA200347512288CC4F85C5F978EFC1
```

## Create a file named as shown below.

`vi aws-efs-csi-driver-trust-policy.json`

## Copy the below content and paste it in the file.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::684206014294:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/0DEA200347512288CC4F85C5F978EFC1"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "oidc.eks.us-east-1.amazonaws.com/id/0DEA200347512288CC4F85C5F978EFC1:sub": "system:serviceaccount:kube-system:efs-csi-*",
          "oidc.eks.us-east-1.amazonaws.com/id/0DEA200347512288CC4F85C5F978EFC1:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}

```

## Create a IAM role using the file which created above

```
aws iam create-role \
  --role-name AmazonEKS_EFS_CSI_DriverRole \
  --assume-role-policy-document file://"aws-efs-csi-driver-trust-policy.json"
```

## Attach the aws managed policy to the role which created above.

```
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy \
  --role-name AmazonEKS_EFS_CSI_DriverRole
```
## Use the below cli command to list addons which are present on the eks cluster in the table format.

```
aws eks describe-addon-versions --kubernetes-version 1.30 \
    --query 'addons[].{MarketplaceProductUrl: marketplaceInformation.productUrl, Name: addonName, Owner: owner Publisher: publisher, Type: type}' --output table
```

## Use the below cli command to list versions of efs csi driver on the eks cluster.

```
aws eks describe-addon-versions \
  --kubernetes-version 1.30 \
  --addon-name aws-efs-csi-driver \
  --query 'addons[].addonVersions[].{Version: addonVersion, Defaultversion: compatibilities[0].defaultVersion}' \
  --output table
```

## Use the below cli command to add efs csi driver addon on the eks cluster.

```
aws eks create-addon --cluster-name basic-cluster --addon-name aws-efs-csi-driver
```

## Copy the EFS id from the console.

`fs-057a8390e1e857692`

## Create pv and pvc using the efs id and mount it in the pod as shown below.

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: efs-pv
spec:
  capacity:
    storage: 5Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: efs.csi.aws.com
    volumeHandle: fs-057a8390e1e857692


apiVersion: v1
kind: PersistentVolumeClaim
metadata:                          
  name: efs-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi

apiVersion: v1
kind: Pod
metadata:
  name: efs-demo-pod
spec:
  containers:
  - name: efs-demo-container
    image: nginx  # Replace with your application container image
    volumeMounts:
    - mountPath: /mnt/efs  # The path inside the container where the volume will be mounted
      name: efs-storage
  volumes:
  - name: efs-storage
    persistentVolumeClaim:
      claimName: efs-pvc

```

```
check the pod status it is running or not.
Go to console check the subnet where the node is running and check in the efs network settings whether it has mount options or not.
After creating mount option in security group open port `2049` 
```





