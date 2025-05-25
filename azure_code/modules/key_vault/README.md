# Terraform Module for Azure Key Vault

## Introduction
This Terraform module deploys an **Azure Key Vault** with configurable access policies, secrets, and role-based access control (RBAC) settings. It enables secure storage and management of sensitive information such as API keys, passwords, and certificates.

## Features
- Creates an **Azure Key Vault** with optional RBAC authorization.
- Configures **access policies** to grant permissions for keys, secrets, and certificates.
- Generates an **HSM-backed key** with rotation policies.
- Supports **Key Vault secrets** for securely storing sensitive data.
- Provides flexibility with **dynamic access policies** based on module input.

## Usage
### Example Usage
```hcl
module "keyvault" {
  source = "./modules/key_vault"
  resource_group_name        = "python1234"
  key_vault_name = "key-vault-tesr"
  sku_name       = "standard"
  hsm_key_name = "keyvault-hsm"
  key_size = 2048
  key_type = "RSA-HSM"
  enabled_for_deployment      = false
  enabled_for_disk_encryption = false
  enable_rbac_authorization   = false
  purge_protection_enabled    = true
  access_policies = [
    {
      key_permissions         = ["Create", "Get", "List"]
      secret_permissions      = ["Get", "List", "Set", "Delete", "Purge"]
      certificate_permissions = ["Get", "List"]
    }
  ]
  key_vault_secrets = {
    "db-password"  = "SuperSecretPassword!"
    "api-key"      = "API-KEY-1234"
    "storage-key"  = "StorageAccessKey=="
  }
  tags = {
    owner       = "admin"
  }
}
```

## Inputs
| Name                      | Type        | Default | Description |
|---------------------------|------------|---------|-------------|
| `key_vault_name`          | `string`   | n/a     | The name of the Key Vault. |
| `resource_group_name`     | `string`   | n/a     | The name of the existing Resource Group where Key Vault will be deployed. |
| `sku_name`                | `string`   | `standard` | SKU tier of the Key Vault (`standard` or `premium`). |
| `enabled_for_deployment`  | `bool`     | `false` | Whether the Key Vault is enabled for deployment. |
| `enabled_for_disk_encryption` | `bool` | `false` | Whether the Key Vault is enabled for disk encryption. |
| `enable_rbac_authorization` | `bool`   | `false` | Enables or disables RBAC authorization on the Key Vault. |
| `purge_protection_enabled` | `bool`    | `false` | Enables or disables purge protection on the Key Vault. |
| `tags`                    | `map`      | `{}`    | Tags to be applied to the Key Vault. |
| `access_policies`         | `list`     | `[]`    | List of access policies to be applied. |
| `hsm_key_name`                | `string`     | Name of the Key Vault key. |
| `key_type`                    | `string`     | Type of key (e.g., `RSA`, `EC`). |
| `key_size`                    | `number`     | Size of the key (e.g., 2048, 4096). |
| `key_vault_secrets`       | `map`      | `{}`    | Key-value pairs representing secrets to be stored in the Key Vault. |

## Outputs
| Name              | Description |
|------------------|-------------|
| `key_vault_id`  | The ID of the created Key Vault. |
| `key_vault_uri` | The URI to access the Key Vault. |
| `hsm_key_id`         | The ID of the created Key Vault Key. |


## Resources Created
- `azurerm_key_vault`
- `azurerm_key_vault_secret`
- `azurerm_key_vault_key`

## Notes
- If `enable_rbac_authorization` is set to `true`, **RBAC roles** must be assigned separately, as this module does not handle RBAC assignments.
- If `purge_protection_enabled` is set to `true`, **Key Vault deletion** will be restricted for a defined retention period.