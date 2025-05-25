# Terraform Module: Azure Container Registry (ACR)

## Overview

This Terraform module provisions an **Azure Container Registry (ACR)** with optional features such as **private endpoints**, **customer-managed key (CMK) encryption**, **scope maps and tokens**, and **diagnostic monitoring**. It supports integration with existing **resource groups**, **virtual networks**, and **subnets**.

## Features

- Creates an Azure Container Registry with system-assigned or user-assigned managed identity.
- Supports customer-managed key (CMK) encryption using Azure Key Vault.
- Optionally creates **scope maps** and **tokens** for granular access control.
- Enables private endpoint integration with DNS zone linking.
- Configures diagnostic settings to forward logs and metrics to **Log Analytics**.

## Usage

```hcl
module "acr" {
  source = "./modules/acr"

  acr_name                        = "myacrregistry"
  resource_group                 = "my-resource-group"
  vnet_name                      = "my-vnet"
  subnet_name                    = "acr-subnet"
  sku                            = "Premium"
  admin_enabled                  = true
  public_network_access_enabled = false
  enable_private_endpoint        = true
  encryption_enabled             = true
  key_vault_key_id               = "https://my-keyvault.vault.azure.net/keys/my-key"
  log_analytics_workspace_id     = "your-log-analytics-workspace-id"
  enable_diagnostics             = true

  network_rule_set = {
    default_action = "Deny"
    ip_rules = [
      {
        action   = "Allow"
        ip_range = "192.168.1.0/24"
      }
    ]
  }

  scope_map = {
    dev = {
      actions = [
        "repositories/myrepo/content/read",
        "repositories/myrepo/content/write"
      ]
    }
  }

  tags = {
    environment = "production"
  }
}
```

## Inputs

| Name                          | Type          | Description                                                                 |
|-------------------------------|---------------|-----------------------------------------------------------------------------|
| acr_name                     | string        | Name of the Azure Container Registry.                                       |
| resource_group               | string        | Name of the existing resource group.                                        |
| vnet_name                    | string        | Name of the existing virtual network.                                       |
| subnet_name                  | string        | Name of the existing subnet for private endpoint.                           |
| sku                          | string        | SKU tier of the ACR (Basic, Standard, or Premium).                          |
| admin_enabled                | bool          | Enable the ACR admin user.                                                  |
| public_network_access_enabled| bool          | Enable public network access to the registry.                               |
| enable_private_endpoint      | bool          | Create a private endpoint with DNS link if true.                            |
| encryption_enabled           | bool          | Enable customer-managed key encryption.                                     |
| key_vault_key_id             | string        | Key Vault key URI for encryption (required if encryption is enabled).       |
| network_rule_set             | object        | IP-based access rules (default action, IP rules).                           |
| scope_map                    | map(object)   | Optional scope maps and associated actions for tokens.                      |
| enable_diagnostics           | bool          | Enable diagnostic settings for monitoring.                                  |
| log_analytics_workspace_id   | string        | ID of the Log Analytics Workspace for diagnostics.                          |
| tags                         | map(string)   | Tags to apply to all created resources.                                     |

## Outputs

| Name                  | Description                                                   |
|-----------------------|---------------------------------------------------------------|
| acr_id                | The ID of the Azure Container Registry.                      |
| acr_login_server      | The login server URL for the ACR.                            |
| acr_private_endpoint_id   | ID of the ACR private endpoint (only if `enable_private_endpoint` is true). |

## Notes

- Private endpoint is created only if `enable_private_endpoint` is set to `true`.
- To use customer-managed key (CMK) encryption, ensure `encryption_enabled = true` and `key_vault_key_id` is provided.
- Scope maps and tokens allow fine-grained access for container repositories.
- All logs and metrics are sent to the specified Log Analytics Workspace when diagnostics are enabled.

