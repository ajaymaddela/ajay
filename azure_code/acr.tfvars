acr_name                        = "ajaymad231"
sku                             = "Premium"
admin_enabled                   = true
public_network_access_enabled   = false
enable_private_endpoint         = false
enable_diagnostics              = false
encryption_enabled              = false
network_rule_set = {
  default_action = "Deny"
  ip_rules = [
    {
      action   = "Allow"
      ip_range = "106.222.235.202/32"
    }
  ]
}

# scope_map = {
#   "acr-cleanup-scope" = {
#     actions = [
#       "repositories/*/content/delete",
#       "repositories/*/metadata/read",
#       "repositories/*/metadata/write",
#       "repositories/*/content/read"
#     ]
#   }
# }
tags = {
  environment = "dev"
  project     = "acr-module"
}