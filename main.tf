##-----------------------------------------------------------------------------
# Standard Tagging Module – Applies standard tags to all resources for traceability
##-----------------------------------------------------------------------------

module "labels" {
  source          = "terraform-az-modules/tags/azurerm"
  version         = "1.0.2"
  name            = var.custom_name == null ? var.name : var.custom_name
  location        = var.location
  environment     = var.environment
  managedby       = var.managedby
  label_order     = var.label_order
  repository      = var.repository
  deployment_mode = var.deployment_mode
  extra_tags      = var.extra_tags
}

##-----------------------------------------------------------------------------
## Random Password Resource.
## Will be passed as admin password of mysql server when admin password is not passed manually as variable.
##-----------------------------------------------------------------------------
resource "random_password" "main" {
  count       = var.enabled && var.administrator_login_password == null ? 1 : 0
  length      = var.admin_password_length
  min_upper   = var.min_upper
  min_lower   = var.min_lower
  min_numeric = var.min_numeric
  special     = var.special
}

##-----------------------------------------------------------------------------
## Managed Identity - Deploy user-assigned identity, Key Vault, Role Assignment for MSSQL DB encryption
##-----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "identity" {
  count               = var.enabled && var.encryption ? 1 : 0
  location            = var.location
  name                = var.resource_position_prefix ? format("mid-mssql-%s", local.name) : format("%s-mid-mssql", local.name)
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_key" "main" {
  count           = var.enabled && var.encryption ? 1 : 0
  name            = var.resource_position_prefix ? format("cmk-key-mssql-server-%s", local.name) : format("%s-cmk-key-mssql-server", local.name)
  key_vault_id    = var.key_vault_id
  key_type        = var.key_type
  key_size        = var.key_size
  expiration_date = var.key_expiration_date
  key_opts        = var.key_permissions
  dynamic "rotation_policy" {
    for_each = var.rotation_policy_config.enabled ? [1] : []
    content {
      automatic {
        time_before_expiry = var.rotation_policy_config.time_before_expiry
      }
      expire_after         = var.rotation_policy_config.expire_after
      notify_before_expiry = var.rotation_policy_config.notify_before_expiry
    }
  }
}

resource "azurerm_role_assignment" "sql_cmk_key_data" {
  count = var.enabled && var.encryption ? 1 : 0

  principal_id         = azurerm_user_assigned_identity.identity[0].principal_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  scope                = var.key_vault_id
}

#tfsec:ignore:azure-database-no-public-access  ### No argument-reference found on terraform registry
#tfsec:ignore:azure-database-secure-tls-policy ### No argument-reference found on terraform registry
#tfsec:ignore:azure-database-enable-audit      ### No argument-reference found on terraform registry
resource "azurerm_mssql_server" "primary" {
  count                                        = var.enabled ? 1 : 0
  name                                         = var.enable_failover_group ? (var.resource_position_prefix ? format("mssql-primary-%s", local.name) : format("%s-primary-mssql", local.name)) : (var.resource_position_prefix ? format("mssql-%s", local.name) : format("%s-mssql", local.name))
  resource_group_name                          = var.resource_group_name
  location                                     = var.location
  version                                      = var.sql_server_version
  administrator_login                          = var.azuread_administrator == null ? var.administrator_login : null
  administrator_login_password                 = var.azuread_administrator == null ? (var.administrator_login_password != null ? var.administrator_login_password : random_password.main[0].result) : null
  administrator_login_password_wo              = var.administrator_login_password_wo
  administrator_login_password_wo_version      = var.administrator_login_password_wo_version
  connection_policy                            = var.connection_policy
  express_vulnerability_assessment_enabled     = var.express_vulnerability_assessment_enabled
  transparent_data_encryption_key_vault_key_id = var.encryption ? azurerm_key_vault_key.main[0].id : var.transparent_data_encryption_key_vault_key_id
  public_network_access_enabled                = var.public_network_access_enabled
  outbound_network_restriction_enabled         = var.outbound_network_restriction_enabled
  primary_user_assigned_identity_id            = var.encryption ? azurerm_user_assigned_identity.identity[0].id : var.identity_ids != null ? var.primary_user_assigned_identity_id : null
  minimum_tls_version                          = var.minimum_tls_version

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? [var.azuread_administrator] : []
    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      tenant_id                   = azuread_administrator.value.tenant_id
      azuread_authentication_only = azuread_administrator.value.azuread_authentication_only
    }
  }

  dynamic "identity" {
    for_each = var.encryption || var.identity_ids != null ? [1] : [1]

    content {
      type         = var.encryption || var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
      identity_ids = var.encryption ? [azurerm_user_assigned_identity.identity[0].id] : var.identity_ids
    }
  }

  tags = module.labels.tags

  lifecycle {
    ignore_changes = [administrator_login_password]
  }
  depends_on = [azurerm_role_assignment.sql_cmk_key_data]

}

resource "azurerm_mssql_server_extended_auditing_policy" "primary" {
  count                                   = var.enabled && var.enable_sql_server_extended_auditing_policy ? 1 : 0
  server_id                               = azurerm_mssql_server.primary[0].id
  storage_endpoint                        = var.storage_account_blob_endpoint
  storage_account_access_key              = var.storage_account_access_key
  storage_account_access_key_is_secondary = var.storage_account_access_key_is_secondary
  retention_in_days                       = var.log_retention_days
  storage_account_subscription_id         = var.storage_account_subscription_id
  predicate_expression                    = var.predicate_expression
  audit_actions_and_groups                = var.audit_actions_and_groups
  log_monitoring_enabled                  = var.enable_log_monitoring
  depends_on                              = [azurerm_mssql_server.primary]
}

resource "azurerm_mssql_server_microsoft_support_auditing_policy" "primary" {
  count                           = var.enabled && var.enable_microsoft_support_auditing_policy ? 1 : 0
  server_id                       = azurerm_mssql_server.primary[0].id
  blob_storage_endpoint           = var.storage_account_blob_endpoint
  storage_account_access_key      = var.storage_account_access_key
  log_monitoring_enabled          = var.enable_log_monitoring
  storage_account_subscription_id = var.storage_account_subscription_id
}

resource "azurerm_mssql_server" "secondary" {
  count                                        = var.enabled && var.enable_failover_group ? 1 : 0
  name                                         = format(var.resource_position_prefix ? "mssql-server-secondary-%s" : "%s-secondary-server-mssql", local.name)
  resource_group_name                          = var.resource_group_name
  location                                     = var.secondary_sql_server_location == null ? var.location : var.secondary_sql_server_location
  version                                      = var.sql_server_version
  administrator_login                          = var.administrator_login
  administrator_login_password                 = var.azuread_administrator == null ? (var.administrator_login_password != null ? var.administrator_login_password : random_password.main[0].result) : null
  administrator_login_password_wo              = var.administrator_login_password_wo
  administrator_login_password_wo_version      = var.administrator_login_password_wo_version
  connection_policy                            = var.connection_policy
  express_vulnerability_assessment_enabled     = var.express_vulnerability_assessment_enabled
  transparent_data_encryption_key_vault_key_id = var.encryption ? azurerm_key_vault_key.main[0].id : var.transparent_data_encryption_key_vault_key_id
  public_network_access_enabled                = var.public_network_access_enabled
  outbound_network_restriction_enabled         = var.outbound_network_restriction_enabled
  primary_user_assigned_identity_id            = var.encryption ? azurerm_user_assigned_identity.identity[0].id : var.identity_ids != null ? var.primary_user_assigned_identity_id : null
  minimum_tls_version                          = var.minimum_tls_version
  tags                                         = module.labels.tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator != null ? [var.azuread_administrator] : []
    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      tenant_id                   = azuread_administrator.value.tenant_id
      azuread_authentication_only = azuread_administrator.value.azuread_authentication_only
    }
  }

  dynamic "identity" {
    for_each = var.encryption || var.identity_ids != null ? [1] : [1]

    content {
      type         = var.encryption || var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
      identity_ids = var.encryption ? [azurerm_user_assigned_identity.identity[0].id] : var.identity_ids
    }
  }

  lifecycle {
    ignore_changes = [administrator_login_password]
  }
  depends_on = [azurerm_mssql_server.primary, azurerm_mssql_database.db, azurerm_role_assignment.sql_cmk_key_data]
}

resource "azurerm_mssql_server_extended_auditing_policy" "secondary" {
  count                                   = var.enabled && var.enable_failover_group && var.enable_sql_server_extended_auditing_policy ? 1 : 0
  server_id                               = azurerm_mssql_server.secondary[0].id
  storage_endpoint                        = var.storage_account_blob_endpoint
  storage_account_access_key              = var.storage_account_access_key
  storage_account_access_key_is_secondary = var.storage_account_access_key_is_secondary
  retention_in_days                       = var.log_retention_days
  storage_account_subscription_id         = var.storage_account_subscription_id
  predicate_expression                    = var.predicate_expression
  audit_actions_and_groups                = var.audit_actions_and_groups
  log_monitoring_enabled                  = var.enable_log_monitoring
  depends_on                              = [azurerm_mssql_server.secondary]
}

resource "azurerm_mssql_server_microsoft_support_auditing_policy" "secondary" {
  count                           = var.enabled && var.enable_microsoft_support_auditing_policy && var.enable_failover_group ? 1 : 0
  server_id                       = azurerm_mssql_server.secondary[0].id
  blob_storage_endpoint           = var.storage_account_blob_endpoint
  storage_account_access_key      = var.storage_account_access_key
  log_monitoring_enabled          = var.enable_log_monitoring
  storage_account_subscription_id = var.storage_account_subscription_id
}


#--------------------------------------------------------------------
# SQL Database creation - Default edition:"Standard" and objective:"S1"
#--------------------------------------------------------------------
resource "azurerm_mssql_database" "db" {
  for_each = var.enabled && var.enable_mssql_db ? var.databases : {}

  name      = each.key
  server_id = azurerm_mssql_server.primary[0].id

  auto_pause_delay_in_minutes                                = try(each.value.auto_pause_delay_in_minutes, null)
  create_mode                                                = try(each.value.create_mode, null)
  creation_source_database_id                                = try(each.value.creation_source_database_id, null)
  collation                                                  = try(each.value.collation, null)
  elastic_pool_id                                            = try(each.value.use_elasticpool, false) ? azurerm_mssql_elasticpool.elasticpool[0].id : try(each.value.elastic_pool_id, null)
  enclave_type                                               = try(each.value.enclave_type, null)
  geo_backup_enabled                                         = try(each.value.geo_backup_enabled, null)
  maintenance_configuration_name                             = try(each.value.maintenance_configuration_name, null)
  ledger_enabled                                             = try(each.value.ledger_enabled, null)
  license_type                                               = try(each.value.license_type, null)
  max_size_gb                                                = try(each.value.max_size_gb, null)
  min_capacity                                               = try(each.value.min_capacity, null)
  restore_point_in_time                                      = try(each.value.restore_point_in_time, null)
  recover_database_id                                        = try(each.value.recover_database_id, null)
  recovery_point_id                                          = try(each.value.recovery_point_id, null)
  restore_dropped_database_id                                = try(each.value.restore_dropped_database_id, null)
  restore_long_term_retention_backup_id                      = try(each.value.restore_long_term_retention_backup_id, null)
  read_replica_count                                         = try(each.value.read_replica_count, null)
  read_scale                                                 = try(each.value.read_scale, null)
  sample_name                                                = try(each.value.sample_name, null)
  sku_name                                                   = try(each.value.sku_name, null)
  storage_account_type                                       = try(each.value.storage_account_type, null)
  transparent_data_encryption_enabled                        = try(each.value.transparent_data_encryption_enabled, null)
  transparent_data_encryption_key_vault_key_id               = var.encryption ? azurerm_key_vault_key.main[0].id : try(each.value.transparent_data_encryption_key_vault_key_id, var.transparent_data_encryption_key_vault_key_id)
  transparent_data_encryption_key_automatic_rotation_enabled = try(each.value.transparent_data_encryption_key_automatic_rotation_enabled, null)
  zone_redundant                                             = try(each.value.zone_redundant, null)
  secondary_type                                             = try(each.value.secondary_type, null)

  tags = merge(
    module.labels.tags,
    try(each.value.tags, {})
  )

  dynamic "import" {
    for_each = try(each.value.import, null) == null ? [] : [each.value.import]
    content {
      storage_uri                  = import.value.storage_uri
      storage_key                  = try(import.value.storage_key, null)
      storage_key_type             = try(import.value.storage_key_type, null)
      administrator_login          = import.value.administrator_login
      administrator_login_password = try(import.value.administrator_login_password, null)
      authentication_type          = import.value.authentication_type
      storage_account_id           = try(import.value.storage_account_id, null)
    }
  }

  dynamic "threat_detection_policy" {
    for_each = try(each.value.threat_detection_policy, null) == null ? [] : [each.value.threat_detection_policy]
    content {
      state                      = try(threat_detection_policy.value.state, null)
      disabled_alerts            = try(threat_detection_policy.value.disabled_alerts, null)
      email_account_admins       = try(threat_detection_policy.value.email_account_admins, null)
      email_addresses            = try(threat_detection_policy.value.email_addresses, null)
      retention_days             = try(threat_detection_policy.value.retention_days, null)
      storage_account_access_key = try(threat_detection_policy.value.storage_account_access_key, null)
      storage_endpoint           = try(threat_detection_policy.value.storage_endpoint, null)
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = try(each.value.long_term_retention_policy, null) == null ? [] : [each.value.long_term_retention_policy]
    content {
      weekly_retention          = try(long_term_retention_policy.value.weekly_retention, null)
      monthly_retention         = try(long_term_retention_policy.value.monthly_retention, null)
      yearly_retention          = try(long_term_retention_policy.value.yearly_retention, null)
      week_of_year              = try(long_term_retention_policy.value.week_of_year, null)
      immutable_backups_enabled = try(long_term_retention_policy.value.immutable_backups_enabled, null)
    }
  }

  dynamic "short_term_retention_policy" {
    for_each = try(each.value.short_term_retention_policy, null) == null ? [] : [each.value.short_term_retention_policy]
    content {
      retention_days           = try(short_term_retention_policy.value.retention_days, null)
      backup_interval_in_hours = try(short_term_retention_policy.value.backup_interval_in_hours, null)
    }
  }

  dynamic "identity" {
    for_each = var.encryption ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.identity[0].id]
    }
  }

  depends_on = [azurerm_mssql_server.primary]
}

resource "azurerm_mssql_database_extended_auditing_policy" "primary" {
  for_each = var.enabled && var.enable_database_extended_auditing_policy ? azurerm_mssql_database.db : {}

  database_id                             = each.value.id
  storage_endpoint                        = var.storage_account_blob_endpoint
  storage_account_access_key              = var.storage_account_access_key
  storage_account_access_key_is_secondary = var.storage_account_access_key_is_secondary
  retention_in_days                       = var.log_retention_days
  log_monitoring_enabled                  = var.enable_log_monitoring

  depends_on = [azurerm_mssql_database.db]
}

#-----------------------------------------------------------------------------------------------
# SQL ServerVulnerability assessment and alert to admin team  - Default is "false"
#-----------------------------------------------------------------------------------------------

resource "azurerm_mssql_server_security_alert_policy" "sap_primary" {
  count                      = var.enabled && var.enable_security_alert_policy ? 1 : 0
  resource_group_name        = var.resource_group_name
  server_name                = azurerm_mssql_server.primary[0].name
  state                      = var.state
  email_account_admins       = var.email_account_admins
  email_addresses            = var.email_addresses_for_alerts
  retention_days             = var.threat_detection_audit_logs_retention_days
  disabled_alerts            = var.disabled_alerts
  storage_account_access_key = var.storage_account_access_key
  storage_endpoint           = var.storage_account_blob_endpoint
}

resource "azurerm_mssql_server_security_alert_policy" "sap_secondary" {
  count                      = var.enabled && var.enable_security_alert_policy && var.enable_failover_group ? 1 : 0
  resource_group_name        = var.resource_group_name
  server_name                = azurerm_mssql_server.secondary[0].name
  state                      = var.state
  email_account_admins       = var.email_account_admins
  email_addresses            = var.email_addresses_for_alerts
  retention_days             = var.threat_detection_audit_logs_retention_days
  disabled_alerts            = var.disabled_alerts
  storage_account_access_key = var.storage_account_access_key
  storage_endpoint           = var.storage_account_blob_endpoint
}

resource "azurerm_mssql_server_vulnerability_assessment" "va_primary" {
  count                           = var.enabled && var.enable_vulnerability_assessment ? 1 : 0
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sap_primary[0].id
  storage_container_path          = var.storage_container_path
  storage_account_access_key      = var.storage_account_access_key
  storage_container_sas_key       = var.storage_container_sas_key

  dynamic "recurring_scans" {
    for_each = var.recurring_scans == null ? {} : var.recurring_scans
    content {
      enabled                   = recurring_scans.value.enabled
      email_subscription_admins = recurring_scans.value.email_subscription_admins
      emails                    = recurring_scans.value.emails
    }
  }
}

resource "azurerm_mssql_database_vulnerability_assessment_rule_baseline" "db_va_primary" {
  for_each = var.enabled && var.enable_vulnerability_assessment_rule_baseline ? azurerm_mssql_database.db : {}

  server_vulnerability_assessment_id = azurerm_mssql_server_vulnerability_assessment.va_primary[0].id
  database_name                      = each.value.name
  rule_id                            = var.rule_id
  baseline_name                      = var.baseline_name

  baseline_result {
    result = var.baseline_result
  }
}

resource "azurerm_mssql_server_vulnerability_assessment" "va_secondary" {
  count                           = var.enabled && var.enable_vulnerability_assessment && var.enable_failover_group ? 1 : 0
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sap_secondary[0].id
  storage_container_path          = var.storage_container_path
  storage_account_access_key      = var.storage_account_access_key
  storage_container_sas_key       = var.storage_container_sas_key

  dynamic "recurring_scans" {
    for_each = var.recurring_scans == null ? {} : var.recurring_scans
    content {
      enabled                   = recurring_scans.value.enabled
      email_subscription_admins = recurring_scans.value.email_subscription_admins
      emails                    = recurring_scans.value.emails
    }
  }
}

##---------------------------------------------------------------------------------------------
## Job
##---------------------------------------------------------------------------------------------
resource "azurerm_mssql_job_agent" "ja_primary" {
  count       = var.enabled && var.enable_job_agent ? 1 : 0
  name        = format(var.resource_position_prefix ? "mssql-ja-%s" : "%s-ja-mssql", local.name)
  location    = var.location
  database_id = azurerm_mssql_database.db[var.job_agent_database_key].id
  sku         = var.ja_sku
}

resource "azurerm_mssql_job_credential" "jc_primary" {
  for_each            = var.enabled && var.job_credentials != null ? var.job_credentials : {}
  name                = each.key
  job_agent_id        = azurerm_mssql_job_agent.ja_primary[0].id
  username            = each.value.username
  password            = each.value.password
  password_wo         = each.value.password_wo
  password_wo_version = each.value.password_wo_version
}

resource "azurerm_mssql_job_target_group" "jtg_primary" {
  for_each = var.enabled && var.job_target_group != null ? var.job_target_group : {}

  name         = each.key
  job_agent_id = azurerm_mssql_job_agent.ja_primary[0].id

  dynamic "job_target" {
    for_each = each.value.databases
    content {
      server_name       = azurerm_mssql_server.primary[0].name
      database_name     = job_target.value
      membership_type   = each.value.membership_type
      job_credential_id = length(try(each.value.job_credential_id, "")) > 0 ? each.value.job_credential_id : null
      elastic_pool_name = length(try(each.value.elastic_pool_name, "")) > 0 ? each.value.elastic_pool_name : null
    }
  }
}

resource "azurerm_mssql_job" "job_primary" {
  for_each     = var.enabled && var.job != null ? var.job : {}
  name         = each.key
  job_agent_id = azurerm_mssql_job_agent.ja_primary[0].id
  description  = each.value.description
}

resource "azurerm_mssql_job_schedule" "js_primary" {
  for_each   = var.enabled && var.job_schedule != null ? var.job_schedule : {}
  job_id     = azurerm_mssql_job.job_primary[each.key].id
  type       = each.value.schedule_type
  enabled    = each.value.schedule_enable
  end_time   = each.value.schedule_end_time
  interval   = each.value.schedule_interval
  start_time = each.value.schedule_start_time
}

resource "azurerm_mssql_job_step" "js_primary" {
  for_each                          = var.enabled && var.job_step != null ? var.job_step : {}
  name                              = each.key
  job_id                            = azurerm_mssql_job.job_primary[each.key].id
  job_step_index                    = each.value.job_step_index
  job_target_group_id               = azurerm_mssql_job_target_group.jtg_primary[each.key].id
  sql_script                        = each.value.sql_script
  initial_retry_interval_seconds    = each.value.initial_retry_interval_seconds
  job_credential_id                 = try(azurerm_mssql_job_credential.jc_primary[each.key].id, null)
  maximum_retry_interval_seconds    = each.value.maximum_retry_interval_seconds
  retry_attempts                    = each.value.retry_attempts
  retry_interval_backoff_multiplier = each.value.retry_interval_backoff_multiplier
  timeout_seconds                   = each.value.timeout_seconds

  dynamic "output_target" {
    for_each = each.value.output_target != null ? each.value.output_target : {}
    content {
      mssql_database_id = azurerm_mssql_database.db[output_target.value.database_key].id
      table_name        = output_target.value.table_name
      job_credential_id = try(output_target.value.job_credential_id, null)
      schema_name       = try(output_target.value.schema_name, "dbo")
    }
  }
}

#-----------------------------------------------------------------------------------------------
# Create and initialize a Microsoft SQL Server database using sqlcmd utility - Default is "false"
#-----------------------------------------------------------------------------------------------
resource "null_resource" "create_sql" {
  for_each = var.initialize_sql_script_execution ? azurerm_mssql_database.db : {}

  provisioner "local-exec" {
    command = "sqlcmd -I -U ${azurerm_mssql_server.primary[0].administrator_login} -P ${azurerm_mssql_server.primary[0].administrator_login_password} -S ${azurerm_mssql_server.primary[0].fully_qualified_domain_name} -d ${each.value.name} -i ${var.sqldb_init_script_file} -o ${format("%s-%s.log", replace(var.sqldb_init_script_file, ".sql", ""), each.key)}"
  }
}

#---------------------------------------------------------
# Azure SQL Firewall Rule - Default is "false"
#---------------------------------------------------------

resource "azurerm_mssql_firewall_rule" "fw01" {
  for_each         = var.enabled && var.enable_firewall_rules ? var.firewall_rules : {}
  name             = each.key
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
  server_id        = azurerm_mssql_server.primary[0].id
}

resource "azurerm_mssql_firewall_rule" "fw02" {
  for_each         = var.enabled && var.enable_failover_group && var.enable_failover_firewall_rules ? var.firewall_rules : {}
  name             = each.key
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
  server_id        = azurerm_mssql_server.secondary[0].id
}

##----------------------------------------------------------------------------
## DNS Alias
##----------------------------------------------------------------------------

resource "azurerm_mssql_server_dns_alias" "dns" {
  count           = var.enabled && var.enable_dns_alias ? 1 : 0
  name            = format(var.resource_position_prefix ? "mssql-server-dns-%s" : "%s-dns-server-mssql", local.name)
  mssql_server_id = azurerm_mssql_server.primary[0].id
  depends_on      = [azurerm_mssql_server.primary]
}

##----------------------------------------------------------------------------
## Transparent Data Encryption
##----------------------------------------------------------------------------

resource "azurerm_mssql_server_transparent_data_encryption" "tde" {
  count                 = var.enabled && var.enable_transparent_data_encryption ? 1 : 0
  server_id             = azurerm_mssql_server.primary[0].id
  key_vault_key_id      = var.encryption ? azurerm_key_vault_key.main[0].id : var.transparent_data_encryption_key_vault_key_id
  managed_hsm_key_id    = var.managed_hsm_key_id
  auto_rotation_enabled = var.auto_rotation_enabled
  depends_on            = [azurerm_key_vault_key.main, azurerm_mssql_server.primary]
}

##-----------------------------------------------------------------------------
## Outbound Firewall Rule
##-----------------------------------------------------------------------------

resource "azurerm_mssql_outbound_firewall_rule" "main" {
  for_each  = var.enabled && var.mssql_outbound_firewall_rule_fqdns != null ? var.mssql_outbound_firewall_rule_fqdns : {}
  name      = each.value
  server_id = azurerm_mssql_server.primary[0].id
}

##----------------------------------------------------------------------------
## Elastic Pool
##----------------------------------------------------------------------------

resource "azurerm_mssql_elasticpool" "elasticpool" {
  count                          = var.enabled && var.enable_elasticpool ? 1 : 0
  name                           = format(var.resource_position_prefix ? "mssql-server-ep-%s" : "%s-ep-server-mssql", local.name)
  resource_group_name            = var.resource_group_name
  location                       = var.location
  server_name                    = azurerm_mssql_server.primary[0].name
  maintenance_configuration_name = var.maintenance_configuration_name
  max_size_gb                    = var.elasticpool_max_size_gb
  max_size_bytes                 = var.max_size_bytes
  enclave_type                   = var.enclave_type
  zone_redundant                 = var.zone_redundant
  license_type                   = var.license_type

  sku {
    name     = var.sku.name
    capacity = var.sku.capacity
    tier     = var.sku.tier
    family   = var.sku.family
  }

  per_database_settings {
    min_capacity = var.per_database_settings.min_capacity
    max_capacity = var.per_database_settings.max_capacity
  }
}

##-----------------------------------------------------------------------------
## Private Endpoint
##-----------------------------------------------------------------------------

resource "azurerm_private_endpoint" "pep_primary" {
  count               = var.enabled && var.enable_private_endpoint ? 1 : 0
  name                = format("pe-%s", azurerm_mssql_server.primary[0].name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = module.labels.tags
  private_service_connection {
    name                           = var.resource_position_prefix ? format("psc-%s", azurerm_mssql_server.primary[0].name) : format("%s-psc", azurerm_mssql_server.primary[0].name)
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.primary[0].id
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = var.resource_position_prefix ? format("dns-zone-group-%s", azurerm_mssql_server.primary[0].name) : format("%s-dns-zone-group", azurerm_mssql_server.primary[0].name)
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "azurerm_private_endpoint" "pep_secondary" {
  count               = var.enabled && var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = format("pe-%s", azurerm_mssql_server.secondary[0].name)
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = module.labels.tags
  private_service_connection {
    name                           = var.resource_position_prefix ? format("psc-%s", azurerm_mssql_server.secondary[0].name) : format("%s-psc", azurerm_mssql_server.secondary[0].name)
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.secondary[0].id
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = var.resource_position_prefix ? format("dns-zone-group-%s", azurerm_mssql_server.secondary[0].name) : format("%s-dns-zone-group", azurerm_mssql_server.secondary[0].name)
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#------------------------------------------------------------------
# azurerm monitoring diagnostics  - Default is "false"
#------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "mssql_db_diag" {
  for_each = var.enabled && var.enable_diagnostic ? azurerm_mssql_database.db : {}

  name = var.resource_position_prefix ? format("Ds-mssql-%s-%s", local.name, each.key) : format("%s-%s-mssql-Ds", local.name, each.key)

  target_resource_id             = each.value.id
  storage_account_id             = var.storage_account_id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id

  dynamic "enabled_metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = enabled_metric.value
    }
  }

  dynamic "enabled_log" {
    for_each = var.log_enabled ? ["allLogs"] : []
    content {
      category_group = enabled_log.value
    }
  }

  lifecycle {
    ignore_changes = [enabled_log, enabled_metric]
  }
}
##---------------------------------------------------------
## Azure SQL Failover Group - Default is "false"
##---------------------------------------------------------
resource "azurerm_mssql_failover_group" "fog" {
  count = var.enabled && var.enable_failover_group ? 1 : 0

  name                                      = format(var.resource_position_prefix ? "mssql-server-fog-%s" : "%s-fog-server-mssql", local.name)
  databases                                 = [for db in values(azurerm_mssql_database.db) : db.id]
  server_id                                 = azurerm_mssql_server.primary[0].id
  readonly_endpoint_failover_policy_enabled = var.readonly_endpoint_failover_policy_enabled

  partner_server {
    id = azurerm_mssql_server.secondary[0].id
  }

  read_write_endpoint_failover_policy {
    mode          = var.read_write_endpoint_failover_policy.mode
    grace_minutes = var.read_write_endpoint_failover_policy.grace_minutes
  }

  depends_on = [
    azurerm_mssql_server.primary,
    azurerm_mssql_server.secondary,
    azurerm_mssql_database.db,
    azurerm_key_vault_key.main,
    azurerm_role_assignment.sql_cmk_key_data,
    azurerm_mssql_server_transparent_data_encryption.tde
  ]
}

##------------------------------------------------------------------------
## Virtual Network Rule
##------------------------------------------------------------------------

resource "azurerm_mssql_virtual_network_rule" "primary" {
  count                                = var.enabled && var.enable_virtual_network_rule ? 1 : 0
  name                                 = format(var.resource_position_prefix ? "mssql-vnet-rule-%s" : "%s-vnet-rule-mssql", local.name)
  server_id                            = azurerm_mssql_server.primary[0].id
  subnet_id                            = var.vnet_rule_subnet_id
  ignore_missing_vnet_service_endpoint = var.ignore_missing_vnet_service_endpoint
}

resource "azurerm_mssql_virtual_network_rule" "secondary" {
  count                                = var.enabled && var.enable_virtual_network_rule ? 1 : 0
  name                                 = format(var.resource_position_prefix ? "mssql-vnet-rule-%s" : "%s-vnet-rule-mssql", local.name)
  server_id                            = azurerm_mssql_server.secondary[0].id
  subnet_id                            = var.vnet_rule_subnet_id
  ignore_missing_vnet_service_endpoint = var.ignore_missing_vnet_service_endpoint
}