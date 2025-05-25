locals {
  use_vnet = var.vnet_integration_enabled
  resolved_dns_label = var.dns_name_label != null ? var.dns_name_label : var.container_instance_name
  resolved_subnet_ids = var.vnet_integration_enabled ? var.subnet_ids : null
  resolved_dns_name_label = var.vnet_integration_enabled ? null : local.resolved_dns_label
}


resource "azurerm_container_group" "aci" {
  name                = var.container_instance_name
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags
  os_type             = title(var.os_type)
  restart_policy      = title(var.restart_policy)
  key_vault_key_id    = try(var.key_vault_key_id, null)

  ip_address_type = var.vnet_integration_enabled && var.os_type == "Linux" ? var.ip_address_type : null
  subnet_ids          = local.resolved_subnet_ids
  dns_name_label      = local.resolved_dns_name_label
  dynamic "identity" {
    for_each = (var.identity_type == "SystemAssigned" && length(var.identity_ids) == 0) ? [1] : []
    content {
      type = var.identity_type
    }
  }

  dynamic "identity" {
    for_each = (var.identity_type == "UserAssigned" || length(var.identity_ids) > 0) ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "identity" {
    for_each = (var.identity_type == "SystemAssigned, UserAssigned") ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "image_registry_credential" {
    for_each = (
      var.settings != null &&
      var.settings.image_registry_credential != null &&
      try(var.settings.image_registry_credential.login_server, null) != null &&
      try(var.settings.image_registry_credential.username, null) != null &&
      try(var.settings.image_registry_credential.password, null) != null
    ) ? [var.settings.image_registry_credential] : []
  
    content {
      server   = image_registry_credential.value.login_server
      username = image_registry_credential.value.username
      password = image_registry_credential.value.password
    }
  }



  dynamic "dns_config" {
    for_each = try([var.settings.dns_config], [])
    content {
      nameservers    = try(tolist(var.settings.dns_config.nameservers), [])
      search_domains = try(tolist(var.settings.dns_config.search_domains), [])
      options        = try(tolist(var.settings.dns_config.options), [])
    }
  }

  dynamic "diagnostics" {
    for_each = try(var.settings.diagnostics.log_analytics.workspace_id, null) != null ? [1] : []
    content {
      log_analytics {
        workspace_id  = var.settings.diagnostics.log_analytics.workspace_id
        workspace_key = var.settings.diagnostics.log_analytics.workspace_key
      }
    }
  }

  dynamic "exposed_port" {
    for_each = try([var.settings.exposed_port], [])
    content {
      port     = var.settings.exposed_port.port
      protocol = upper(var.settings.exposed_port.protocol)
    }
  }

  dynamic "container" {
    for_each = try(var.settings.containers, [])
    content {
      name                         = container.value.name
      image                        = container.value.image
      cpu                          = container.value.cpu
      memory                       = container.value.memory
      environment_variables        = try(container.value.environment_variables, null)
      secure_environment_variables = try(container.value.secure_environment_variables, null)
      commands                     = try(container.value.commands, null)

      dynamic "ports" {
        for_each = try(container.value.ports, [])
        content {
          port     = ports.value.port
          protocol = upper(ports.value.protocol)
        }
      }

      dynamic "readiness_probe" {
        for_each = container.value.readiness_probe != null ? [container.value.readiness_probe] : []
        content {
          exec                  = try(readiness_probe.value.exec, null)
          initial_delay_seconds = try(readiness_probe.value.initial_delay_seconds, null)
          period_seconds        = try(readiness_probe.value.period_seconds, null)
          failure_threshold     = try(readiness_probe.value.failure_threshold, null)
          success_threshold     = try(readiness_probe.value.success_threshold, null)
          timeout_seconds       = try(readiness_probe.value.timeout_seconds, null)

          dynamic "http_get" {
            for_each = try(readiness_probe.value.http_get, null) != null ? [1] : []
            content {
              path   = readiness_probe.value.http_get.path
              port   = readiness_probe.value.http_get.port
              scheme = readiness_probe.value.http_get.scheme
            }
          }
        }
      }

      dynamic "liveness_probe" {
        for_each = container.value.liveness_probe != null ? [container.value.liveness_probe] : []
        content {
          exec                  = try(liveness_probe.value.exec, null)
          initial_delay_seconds = try(liveness_probe.value.initial_delay_seconds, null)
          period_seconds        = try(liveness_probe.value.period_seconds, null)
          failure_threshold     = try(liveness_probe.value.failure_threshold, null)
          success_threshold     = try(liveness_probe.value.success_threshold, null)
          timeout_seconds       = try(liveness_probe.value.timeout_seconds, null)

          dynamic "http_get" {
            for_each = try(liveness_probe.value.http_get, null) != null ? [1] : []
            content {
              path   = liveness_probe.value.http_get.path
              port   = liveness_probe.value.http_get.port
              scheme = liveness_probe.value.http_get.scheme
            }
          }
        }
      }

      dynamic "volume" {
        for_each = container.value.volume != null ? [container.value.volume] : []
        content {
          name                 = volume.value.name
          mount_path           = volume.value.mount_path
          read_only            = volume.value.read_only
          empty_dir            = volume.value.empty_dir
          storage_account_name = volume.value.storage_account_name
          storage_account_key  = volume.value.storage_account_key
          share_name           = volume.value.share_name
          secret               = volume.value.secret

          dynamic "git_repo" {
            for_each = try(volume.value.git_repo, null) != null ? [1] : []
            content {
              url       = volume.value.git_repo.url
              directory = volume.value.git_repo.directory
              revision  = volume.value.git_repo.revision
            }
          }
        }
      }
    }
  }
 
  dynamic "init_container" {
    for_each = var.settings != null && var.settings.init_container != null ? [var.settings.init_container] : []
    content {
      name  = init_container.value.name
      image = init_container.value.image
  
      commands = lookup(init_container.value, "commands", null)
      environment_variables = lookup(init_container.value, "environment_variables", null)
      secure_environment_variables = lookup(init_container.value, "secure_environment_variables", null)
  
      dynamic "volume" {
        for_each = lookup(init_container.value, "volume", null) != null ? [init_container.value.volume] : []
        content {
          name       = volume.value.name
          mount_path = volume.value.mount_path
          read_only  = lookup(volume.value, "read_only", false)
  
          empty_dir            = lookup(volume.value, "empty_dir", null)
          storage_account_name = lookup(volume.value, "storage_account_name", null)
          storage_account_key  = lookup(volume.value, "storage_account_key", null)
          share_name           = lookup(volume.value, "share_name", null)
          secret               = lookup(volume.value, "secret", null)
  
          dynamic "git_repo" {
            for_each = lookup(volume.value, "git_repo", null) != null ? [volume.value.git_repo] : []
            content {
              url       = git_repo.value.url
              directory = git_repo.value.directory
              revision  = git_repo.value.revision
            }
          }
        }
      }
    }
  }

}


resource "azurerm_network_profile" "net_prof" {
  count               = var.vnet_integration_enabled && var.use_legacy_network_profile && var.os_type == "Linux" ? 1 : 0
  location            = var.location
  name                = var.network_profile_name
  resource_group_name = var.rg_name
  tags                = var.tags

  dynamic "container_network_interface" {
    for_each = try([var.settings.container_network_interface], [])
    content {
      name = var.settings.container_network_interface.name

      dynamic "ip_configuration" {
        for_each = try([var.settings.container_network_interface.ip_configuration], [])
        content {
          name      = var.settings.container_network_interface.ip_configuration.name
          subnet_id = var.settings.container_network_interface.ip_configuration.subnet_id
        }
      }
    }
  }
}
