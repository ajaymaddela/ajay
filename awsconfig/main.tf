# module "conformance_pack" {
#   source                 = "./modules/conformance-packs"
#   conformance_pack_name  = "my-custom-pack"
#   yaml_file_path         = "s3.yaml" # Change to any YAML file you want
# }

module "conformance_pack" {
  source                = "./modules/conformance-packs"
  conformance_pack_name = "ajay-testing"
  s3_bucket_name        = "my-config-conformance-packs"
  yaml_file_name        = "s3.yaml"
}

# s3://my-config-conformance-packs/s3.yaml