### To create infrastructure

- Execute the below commands to create private vpc.
- with one private subnet,ec2 instance in private subnet,transit gateway etc.

```
terraform init

terraform plan -var-file="./env/sandbox/values.tfvars"

terraform apply -var-file="./env/sandbox/values.tfvars" -auto-approve
```