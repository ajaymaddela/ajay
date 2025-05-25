# Azure App Services Deployment (Windows & Linux)

## Overview
This Terraform module deploys Azure App Services with:
- Secure deployment in an existing resource group.
- Support for both Linux and Windows Web Apps.
- Application Service Plan for managing compute resources.
- Managed Identity for secure authentication.
- Custom domain and TLS/SSL support.
- Scaling options for handling varying loads.

## Features
- **App Service Plan**: Deploys an App Service Plan for hosting web applications.
- **Managed Identity**: Provides secure authentication for the App Service.
- **Custom Domains & TLS**: Supports custom domain binding and SSL certificate management.
- **Scaling Options**: Supports auto-scaling based on load.
- **VNET Integration**: Allows integration with an existing Virtual Network.
- **Backup Configuration**: Enables backup and restore functionality.
- **Deployment Slots**: Supports multiple deployment slots for blue-green deployments.
- **Authentication & Monitoring**: Includes built-in authentication and monitoring configurations.
- **Network Restrictions**: Supports IP-based and service endpoint restrictions.
- Configurable authentication (Azure Active Directory, OAuth, etc.).
- Managed identities for secure resource access.
- Configurable application stack settings (Node.js, Java, Python, PHP, .NET, Docker).

## Resources Created
- **Resource Group** (Existing resource group used)
- **User Assigned Identity** (Optional)
- **Storage Account & Container** (For backup, if enabled)
- **Azure App Service Plan**
- **Azure Linux Web App** (if `os_type` is `Linux`)
- **Azure Windows Web App** (if `os_type` is `Windows`)

## Inputs
| Name | Type | Description | Default |
|------|------|-------------|---------|
| `resource_group_name` | `string` | Name of the existing resource group | n/a |
| `location` | `string` | Azure region for deployment | `West Europe` |
| `app_service_name` | `string` | Name of the App Service | n/a |
| `app_service_plan` | `string` | Name of the App Service Plan | n/a |
| `os_type` | `string` | Operating system type for App Service (`Linux` or `Windows`) | `Linux` |
| `sku_tier` | `string` | Pricing tier for the App Service Plan | `Standard` |
| `sku_size` | `string` | Size of the App Service Plan | `S1` |
| `custom_domain` | `string` | Custom domain name for the App Service | n/a |
| `enable_ssl` | `bool` | Enable SSL for the App Service | `false` |
| `enable_https` | Force HTTPS connections | `true` |
| `enable_identity` | Enable managed identity | `true` |
| `enable_vnet_integration` | `bool` | Enable VNET integration for the App Service | `false` |
| `application_insights_enabled` | Enable Application Insights | `false` |
| `enable_backup` | `bool` | Enable backup for the App Service | `false` |
| `storage_account_name` | Storage account for backups | - |
| `storage_container_name` | Storage container for backups | `appservice-backup` |
| `enable_deployment_slot` | `bool` | Enable deployment slots for blue-green deployment | `false` |
| `enable_authentication` | `bool` | Enable built-in authentication for App Service | `false` |
| `enable_monitoring` | `bool` | Enable monitoring and logging for App Service | `false` |
| `enable_network_restrictions` | `bool` | Enable IP and service endpoint restrictions | `false` |
| `tags` | `map` | Tags for resources | `{}` |
| `enable_auth_settings` | Enable authentication settings | `false` |
| `default_auth_provider` | Default authentication provider | `AzureActiveDirectory` |
| `token_store_enabled` | Enable token store | `false` |
| `application_stack` | Define application stack settings (e.g., Java, .NET, Node.js, PHP, Docker) | `{}` |

## Linux Web App
### Example Deployment
```tfvars

  app_service_name       = "nodewebapp"
  app_service_plan_name  = "nodeappserviceplan"
  storage_container_name = "appser-container"

  os_type = "Linux"

  application_insights_enabled = true
  application_insights_id      = null
  app_insights_name            = "nodeappinsights"
  application_insights_type    = "web"
  retention_in_days            = 90
  disable_ip_masking           = false
  enable_identity              = true

  # Linux Node.js App Stack
  enable_application_stack = true
  application_stack = {
    node_version = "18-lts"
  }

  app_settings = {
    "WEBSITES_PORT"   = "3000"
    "WEBSITE_STACK"   = "node"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
  }

  default_documents = ["index.js"]
  health_check_path = "/health"
  http2_enabled     = true
  enable_https      = true

  ips_allowed       = ["0.0.0.0/0"]
  scm_ips_allowed   = ["0.0.0.0/0"]

  enable_auth_settings            = false
  default_auth_provider           = "AzureActiveDirectory"
  unauthenticated_client_action   = "RedirectToLoginPage"
  token_store_enabled             = true

  enable_backup = false
  backup_settings = null

  per_site_scaling = true

  tags = {
    Environment = "Development"
    Project     = "nodeapp"
  }

```

## Windows Web App
### Example Deployment
```tfvars

app_service_name       = "windowsapp"
  app_service_plan_name  = "mywindowsappserviceplan"
  storage_container_name = "appser-container"
  os_type               = "Windows"
  application_insights_enabled = true
  application_insights_id      = null
  app_insights_name            = "myappinsights"
  application_insights_type    = "web"
  retention_in_days            = 90
  disable_ip_masking           = false
  enable_identity     = true
  # Windows Application Stack Configuration
  enable_application_stack = true
  application_stack = {
    dotnet_version         = "v6.0" 
  }
  app_settings = {
    "WEBSITES_PORT"   = "80"
    "WEBSITE_STACK"   = "dotnet"
  }
  default_documents = ["index.html", "default.html"]
  health_check_path = "/health"
  http2_enabled     = true
  enable_https      = true
  ips_allowed    = ["0.0.0.0/0"]
  scm_ips_allowed = ["0.0.0.0/0"]
  enable_auth_settings            = false
  default_auth_provider           = "AzureActiveDirectory"
  unauthenticated_client_action   = "RedirectToLoginPage"
  token_store_enabled             = true
  enable_backup = true
  backup_settings = {
    name                = "DefaultBackup"
    enabled             = true
    frequency_interval  = 24
    frequency_unit      = "Hour"
    start_time          = "2025-04-04T00:00:00Z"
  }
  per_site_scaling = true
  tags = {
    Environment = "Development"
    Project     = "newapp"
  }
```

## Outputs
| Name | Description |
|------|-------------|
| `linux_web_app_id` | ID of the deployed App Service |
| `service_plan_id` | ID of the deployed App Service Plan |

## Notes
- **Supports both Linux and Windows Web Apps**: Define `os_type` as `Linux` or `Windows`.
- **Managed Identity provides authentication**: Use it to securely access Azure resources.
- **Custom domain support**: Configure DNS settings and SSL certificates for a custom domain.
- **Scaling available**: Adjust the App Service Plan to handle traffic demand dynamically.
- **Backup and restore**: Ensure business continuity with automated backups.
- **VNET integration**: Secure your App Service by integrating with a private network.
- **Deployment slots**: Enable blue-green deployments for zero-downtime releases.
- **Monitoring and network security**: Enable logging, authentication, and network restrictions as needed.
