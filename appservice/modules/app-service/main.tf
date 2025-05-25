# Data sources
data "azurerm_resource_group" "rgrp" {
  name = var.resource_group
}

data "azurerm_client_config" "main" {}

resource "azurerm_user_assigned_identity" "user" {
  count               = var.enable_identity ? 1 : 0  # Identity is created only if enabled
  name                = "${data.azurerm_resource_group.rgrp.name}-identity"
  resource_group_name = data.azurerm_resource_group.rgrp.name
  location            = data.azurerm_resource_group.rgrp.location
}
# Local declarations
locals {
  default_site_config = {
    always_on = true
  }

  app_insights = try(data.azurerm_application_insights.main[0], try(azurerm_application_insights.main[0], {}))

  default_app_settings = var.application_insights_enabled ? {
    APPLICATION_INSIGHTS_IKEY                  = try(local.app_insights.instrumentation_key, "")
    APPINSIGHTS_INSTRUMENTATIONKEY             = try(local.app_insights.instrumentation_key, "")
    APPLICATIONINSIGHTS_CONNECTION_STRING      = try(local.app_insights.connection_string, "")
    ApplicationInsightsAgent_EXTENSION_VERSION = "~2"
  } : {}

  ip_restrictions = [
    for ip_address in var.ips_allowed : {
      name                      = "ip_restriction_cidr_${index(var.ips_allowed, ip_address) + 1}"
      ip_address                = ip_address
      virtual_network_subnet_id = null
      service_tag               = null
      subnet_id                 = null
      priority                  = index(var.ips_allowed, ip_address) + 1
      action                    = "Allow"
    }
  ]

  subnet_restrictions = [
    for subnet in var.subnet_ids_allowed : {
      name                      = "ip_restriction_subnet_${index(var.subnet_ids_allowed, subnet) + 1}"
      ip_address                = null
      virtual_network_subnet_id = subnet
      service_tag               = null
      subnet_id                 = subnet
      priority                  = index(var.subnet_ids_allowed, subnet) + 1
      action                    = "Allow"
    }
  ]

  service_tag_restrictions = [
    for service_tag in var.service_tags_allowed : {
      name                      = "service_tag_restriction_${index(var.service_tags_allowed, service_tag) + 1}"
      ip_address                = null
      virtual_network_subnet_id = null
      service_tag               = service_tag
      subnet_id                 = null
      priority                  = index(var.service_tags_allowed, service_tag) + 1
      action                    = "Allow"
    }
  ]

  scm_ip_restrictions = [
    for ip_address in var.scm_ips_allowed : {
      name                      = "scm_ip_restriction_cidr_${index(var.scm_ips_allowed, ip_address) + 1}"
      ip_address                = ip_address
      virtual_network_subnet_id = null
      service_tag               = null
      subnet_id                 = null
      priority                  = index(var.scm_ips_allowed, ip_address) + 1
      action                    = "Allow"
    }
  ]

  scm_subnet_restrictions = [
    for subnet in var.scm_subnet_ids_allowed : {
      name                      = "scm_ip_restriction_subnet_${index(var.scm_subnet_ids_allowed, subnet) + 1}"
      ip_address                = null
      virtual_network_subnet_id = subnet
      service_tag               = null
      subnet_id                 = subnet
      priority                  = index(var.scm_subnet_ids_allowed, subnet) + 1
      action                    = "Allow"
    }
  ]

  scm_service_tag_restrictions = [
    for service_tag in var.scm_service_tags_allowed : {
      name                      = "scm_service_tag_restriction_${index(var.scm_service_tags_allowed, service_tag) + 1}"
      ip_address                = null
      virtual_network_subnet_id = null
      service_tag               = service_tag
      subnet_id                 = null
      priority                  = index(var.scm_service_tags_allowed, service_tag) + 1
      action                    = "Allow"
    }
  ]
}

locals {
  # Combine all restrictions into a single list
  all_ip_restrictions = concat(
    local.ip_restrictions,
    local.subnet_restrictions,
    local.service_tag_restrictions
  )

  all_scm_restrictions = concat(
    local.scm_ip_restrictions,
    local.scm_subnet_restrictions,
    local.scm_service_tag_restrictions
  )
}

# Storage SAS URL
data "azurerm_storage_account" "storeacc" {
  count               = var.enable_backup ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = data.azurerm_resource_group.rgrp.name
}

resource "azurerm_storage_container" "storcont" {
  count                 = var.enable_backup ? 1 : 0
  name                  = var.storage_container_name == null ? "appservice-backup" : var.storage_container_name
  storage_account_id = data.azurerm_storage_account.storeacc[0].id
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "main" {
  count             = var.enable_backup ? 1 : 0
  connection_string = data.azurerm_storage_account.storeacc[0].primary_connection_string
  container_name    = azurerm_storage_container.storcont[0].name
  https_only        = true
  start  = timestamp()
  expiry = timeadd(timestamp(), "8760h")
  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = var.app_service_plan_name == "" ? format("plan-%s", lower(replace(var.app_service_name, "/[[:^alnum:]]/", ""))) : var.app_service_plan_name
  resource_group_name = data.azurerm_resource_group.rgrp.name
  location            = data.azurerm_resource_group.rgrp.location
  os_type             = var.os_type
  sku_name            = "P1v2"
  per_site_scaling_enabled = var.per_site_scaling
  tags                = merge({ "ResourceName" = format("%s", var.app_service_plan_name) }, var.tags, )
}

resource "azurerm_linux_web_app" "main" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = lower(format("app-%s", var.app_service_name))
  resource_group_name = data.azurerm_resource_group.rgrp.name
  location            = data.azurerm_resource_group.rgrp.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = var.enable_https

  site_config {
    always_on                   = lookup(local.default_site_config, "always_on", false)
    app_command_line            = var.app_command_line
    default_documents           = var.default_documents
    health_check_path           = var.health_check_path
    health_check_eviction_time_in_min = 5
    http2_enabled               = var.http2_enabled
    scm_use_main_ip_restriction = var.scm_ips_allowed != [] || var.scm_subnet_ids_allowed != null ? false : true

    dynamic "ip_restriction" {
      for_each = local.all_ip_restrictions
      content {
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = local.all_scm_restrictions
      content {
        ip_address                = scm_ip_restriction.value.ip_address
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        action                    = scm_ip_restriction.value.action
      }
    }

    dynamic "application_stack" {
      for_each = var.enable_application_stack ? [var.application_stack] : []
      content {
        docker_image_name   = lookup(application_stack.value, "docker_image_name", null)
        docker_registry_username = lookup(application_stack.value, "docker_registry_username", null)
        docker_registry_password = lookup(application_stack.value, "docker_registry_password", null)
        docker_registry_url = lookup(application_stack.value, "docker_registry_url", null)
        dotnet_version      = lookup(application_stack.value, "dotnet_version", null)
        java_version        = lookup(application_stack.value, "java_version", null)
        node_version        = lookup(application_stack.value, "node_version", null)
        php_version         = lookup(application_stack.value, "php_version", null)
        python_version      = lookup(application_stack.value, "python_version", null)
        ruby_version        = lookup(application_stack.value, "ruby_version", null)
      }
    }
  }

  app_settings = merge(local.default_app_settings, var.app_settings)

  auth_settings {
    enabled                        = var.enable_auth_settings
    default_provider               = var.default_auth_provider
    allowed_external_redirect_urls = []
    issuer                         = format("https://sts.windows.net/%s/", data.azurerm_client_config.main.tenant_id)
    unauthenticated_client_action  = var.unauthenticated_client_action
    token_store_enabled            = var.token_store_enabled

    dynamic "active_directory" {
      for_each = var.active_directory_auth_settings
      content {
        client_id         = active_directory.value.client_id
        client_secret     = active_directory.value.client_secret
        allowed_audiences = concat(formatlist("https://%s", [format("%s.azurewebsites.net", var.app_service_name)]), [])
      }
    }
  }

  dynamic "storage_account" {
    for_each = var.storage_mounts
    content {
      name         = lookup(storage_account.value, "name")
      type         = lookup(storage_account.value, "type", "AzureFiles")
      account_name = lookup(storage_account.value, "account_name", null)
      share_name   = lookup(storage_account.value, "share_name", null)
      access_key   = lookup(storage_account.value, "access_key", null)
      mount_path   = lookup(storage_account.value, "mount_path", null)
    }
  }

  dynamic "backup" {
    for_each = var.enable_backup ? [{}] : []
    content {
      name                = coalesce(var.backup_settings.name, "DefaultBackup")
      enabled             = var.backup_settings.enabled
      storage_account_url = format("https://${data.azurerm_storage_account.storeacc.0.name}.blob.core.windows.net/${azurerm_storage_container.storcont.0.name}%s", data.azurerm_storage_account_blob_container_sas.main.0.sas)
      schedule {
        frequency_interval = var.backup_settings.frequency_interval
        frequency_unit     = var.backup_settings.frequency_unit
        start_time         = var.backup_settings.start_time
      }
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = lookup(connection_string.value, "name", null)
      type  = lookup(connection_string.value, "type", null)
      value = lookup(connection_string.value, "value", null)
    }
  }

  identity {
    type         = var.enable_identity ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.enable_identity ? [azurerm_user_assigned_identity.user[0].id] : null
  }

  lifecycle {
    ignore_changes = [
      tags,
      site_config,
      backup,
      auth_settings,
      storage_account,
      identity,
      connection_string,
    ]
  }
}

 
# Windows Web App
resource "azurerm_windows_web_app" "main" {
  count = var.os_type == "Windows" ? 1 : 0
  name                = lower(format("app-%s", var.app_service_name))
  resource_group_name = data.azurerm_resource_group.rgrp.name
  location            = data.azurerm_resource_group.rgrp.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = var.enable_https

  site_config {
    always_on                   = lookup(local.default_site_config, "always_on", false)
    app_command_line            = var.app_command_line
    default_documents           = var.default_documents
    health_check_path           = var.health_check_path
    health_check_eviction_time_in_min = 5
    http2_enabled               = var.http2_enabled
    scm_use_main_ip_restriction = var.scm_ips_allowed != [] || var.scm_subnet_ids_allowed != null ? false : true

    dynamic "ip_restriction" {
      for_each = local.all_ip_restrictions
      content {
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action
      }
    }

    dynamic "scm_ip_restriction" {
      for_each = local.all_scm_restrictions
      content {
        ip_address                = scm_ip_restriction.value.ip_address
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        action                    = scm_ip_restriction.value.action
      }
    }
    dynamic "application_stack" {
      for_each = var.enable_application_stack ? [var.application_stack] : []
      content {
        docker_image_name   = lookup(application_stack.value, "docker_image_name", null)
        docker_registry_username = lookup(application_stack.value, "docker_registry_username", null)
        docker_registry_password = lookup(application_stack.value, "docker_registry_password", null)
        docker_registry_url = lookup(application_stack.value, "docker_registry_url", null)
        dotnet_version      = lookup(application_stack.value, "dotnet_version", null)
        java_version        = lookup(application_stack.value, "java_version", null)
        node_version        = lookup(application_stack.value, "node_version", null)
        php_version         = lookup(application_stack.value, "php_version", null)
        
      }
    }
  
  }


  app_settings = merge(local.default_app_settings, var.app_settings)

  auth_settings {
    enabled                        = var.enable_auth_settings
    default_provider               = var.default_auth_provider
    allowed_external_redirect_urls = []
    issuer                         = format("https://sts.windows.net/%s/", data.azurerm_client_config.main.tenant_id)
    unauthenticated_client_action  = var.unauthenticated_client_action
    token_store_enabled            = var.token_store_enabled

    dynamic "active_directory" {
      for_each = var.active_directory_auth_settings

      content {
        client_id         = active_directory.value.client_id
        client_secret     = active_directory.value.client_secret
        allowed_audiences = concat(formatlist("https://%s", [format("%s.azurewebsites.net", var.app_service_name)]), [])
      }
    }
  }

  dynamic "backup" {
    for_each = var.enable_backup ? [{}] : []

    content {
      name                = coalesce(var.backup_settings.name, "DefaultBackup")
      enabled             = var.backup_settings.enabled
      storage_account_url = format("https://${data.azurerm_storage_account.storeacc.0.name}.blob.core.windows.net/${azurerm_storage_container.storcont.0.name}%s", data.azurerm_storage_account_blob_container_sas.main.0.sas)
      schedule {
        frequency_interval = var.backup_settings.frequency_interval
        frequency_unit     = var.backup_settings.frequency_unit
        start_time         = var.backup_settings.start_time
      }
    }
  }

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = lookup(connection_string.value, "name", null)
      type  = lookup(connection_string.value, "type", null)
      value = lookup(connection_string.value, "value", null)
    }
  }

  identity {
    type         = var.enable_identity ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.enable_identity ? [azurerm_user_assigned_identity.user[0].id] : null
  }

  dynamic "storage_account" {
    for_each = var.storage_mounts

    content {
      name         = lookup(storage_account.value, "name")
      type         = lookup(storage_account.value, "type", "AzureFiles")
      account_name = lookup(storage_account.value, "account_name", null)
      share_name   = lookup(storage_account.value, "share_name", null)
      access_key   = lookup(storage_account.value, "access_key", null)
      mount_path   = lookup(storage_account.value, "mount_path", null)
    }
  }


  lifecycle {
    ignore_changes = [
      tags,
      site_config,
      backup,
      auth_settings,
      storage_account,
      identity,
      connection_string,
    ]
  }
}

# Custom domain and Certificate config
resource "azurerm_app_service_certificate" "main" {
  for_each            = var.custom_domains != null ? { for k, v in var.custom_domains : k => v if v != null } : {}
  name                = each.key
  resource_group_name = data.azurerm_resource_group.rgrp.name
  location            = data.azurerm_resource_group.rgrp.location
  pfx_blob            = contains(keys(each.value), "certificate_file") ? filebase64(each.value.certificate_file) : null
  password            = contains(keys(each.value), "certificate_file") ? each.value.certificate_password : null
  key_vault_secret_id = contains(keys(each.value), "certificate_keyvault_certificate_id") ? each.value.certificate_keyvault_certificate_id : null
}

resource "azurerm_app_service_custom_hostname_binding" "cust-host-bind-linux" {
  count = var.os_type == "Linux" ? (var.custom_domains != null ? length(var.custom_domains) : 0) : 0

  hostname            = keys(var.custom_domains)[count.index]
  app_service_name    = azurerm_linux_web_app.main[0].name
  resource_group_name = data.azurerm_resource_group.rgrp.name
  ssl_state           = lookup(azurerm_app_service_certificate.main, keys(var.custom_domains)[count.index], false) != false ? "SniEnabled" : null
  thumbprint          = lookup(azurerm_app_service_certificate.main, keys(var.custom_domains)[count.index], false) != false ? azurerm_app_service_certificate.main[keys(var.custom_domains)[count.index]].thumbprint : null
}

resource "azurerm_app_service_custom_hostname_binding" "cust-host-bind-windows" {
  count = var.os_type == "Windows" ? (var.custom_domains != null ? length(var.custom_domains) : 0) : 0

  hostname            = keys(var.custom_domains)[count.index]
  app_service_name    = azurerm_windows_web_app.main[0].name
  resource_group_name = data.azurerm_resource_group.rgrp.name
  ssl_state           = lookup(azurerm_app_service_certificate.main, keys(var.custom_domains)[count.index], false) != false ? "SniEnabled" : null
  thumbprint          = lookup(azurerm_app_service_certificate.main, keys(var.custom_domains)[count.index], false) != false ? azurerm_app_service_certificate.main[keys(var.custom_domains)[count.index]].thumbprint : null
}

# Application Insights resources
data "azurerm_application_insights" "main" {
  count               = var.application_insights_enabled && var.application_insights_id != null ? 1 : 0
  name                = split("/", var.application_insights_id)[8]
  resource_group_name = split("/", var.application_insights_id)[4]
}

resource "azurerm_application_insights" "main" {
  count               = var.application_insights_enabled && var.application_insights_id == null ? 1 : 0
  name                = lower(format("appi-%s", var.app_insights_name))
  location            = data.azurerm_resource_group.rgrp.location
  resource_group_name = data.azurerm_resource_group.rgrp.name
  application_type    = var.application_insights_type
  retention_in_days   = var.retention_in_days
  disable_ip_masking  = var.disable_ip_masking
  tags                = merge({ "ResourceName" = var.app_insights_name }, var.tags)
}

# App Service Virtual Network Association
resource "azurerm_app_service_virtual_network_swift_connection" "main-linux" {
  count          = var.os_type == "Linux" && var.enable_vnet_integration ? 1 : 0
  app_service_id = azurerm_linux_web_app.main[0].id
  subnet_id      = var.subnet_id
}

resource "azurerm_app_service_virtual_network_swift_connection" "main-windows" {
  count          = var.os_type == "Windows" && var.enable_vnet_integration ? 1 : 0
  app_service_id = azurerm_windows_web_app.main[0].id
  subnet_id      = var.subnet_id
}