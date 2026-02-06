##-----------------------------------------------------------------------------
# Naming Convention
##-----------------------------------------------------------------------------

variable "resource_position_prefix" {
  type        = bool
  default     = false
  description = "If true, prefixes resource names instead of suffixing."
}

variable "custom_name" {
  type        = string
  default     = null
  description = <<EOT
Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.

- If true, the keyword is prepended: "vnet-core-dev".
- If false, the keyword is appended: "core-dev-vnet".

This helps maintain naming consistency based on organizational preferences.
EOT
}

##-----------------------------------------------------------------------------
# Global
##-----------------------------------------------------------------------------

variable "enabled" {
  type        = bool
  default     = true
  description = "Enable or disable creation of all Logic App resources."
}

variable "resource_group_name" {
  type        = string
  default     = null
  description = "Name of the resource group where resources will be deployed."
}

##-----------------------------------------------------------------------------
# Labels
##-----------------------------------------------------------------------------

variable "name" {
  type        = string
  default     = null
  description = "Base name for resources."
}

variable "location" {
  type        = string
  default     = null
  description = "Azure region where resources will be deployed."
}

variable "environment" {
  type        = string
  default     = null
  description = "Deployment environment (e.g., dev, stage, prod)."
}

variable "managedby" {
  type        = string
  default     = "terraform"
  description = "Tag to indicate the tool or team managing the resources."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azurerm-logic-app"
  description = "Repository URL or identifier for traceability."

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Deployment mode identifier (e.g., blue/green, canary)."
}

variable "label_order" {
  type        = list(string)
  default     = ["name", "environment", "location"]
  description = "Order of labels to be used in naming/tagging."
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to all resources."
}

##------------------------------------------------
## Random Password
##------------------------------------------------

variable "admin_password_length" {
  type        = number
  default     = 16
  description = "Length of the randomly generated admin password, if not provided."
}

variable "min_upper" {
  type        = number
  default     = 4
  description = "Minimum number of uppercase letters in the generated password."
}

variable "min_lower" {
  description = "Minimum number of lowercase letters in the generated password."
  type        = number
  default     = 2
}

variable "min_numeric" {
  type        = number
  default     = 4
  description = "Minimum number of numeric characters in the generated password."
}

variable "special" {
  type        = bool
  default     = false
  description = "Whether to include special characters in the generated password."
}

##-------------------------------------------------
## MSSQL Server
##-------------------------------------------------

variable "sql_server_version" {
  type        = string
  default     = null
  description = "The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
}

variable "administrator_login" {
  default     = null
  type        = string
  description = "The administrator login name for the new SQL Server."
}

variable "administrator_login_password" {
  default     = null
  type        = string
  description = "The password associated with the admin_username user."
}

variable "administrator_login_password_wo" {
  type        = string
  default     = null
  description = "Write-only administrator password for the server (not stored in Terraform state)."
}

variable "administrator_login_password_wo_version" {
  type        = string
  default     = null
  description = "The version of the Write-only administrator password for the server."
}

variable "connection_policy" {
  type        = string
  default     = "Default"
  description = "The connection policy the server will use."

  validation {
    condition     = contains(["Default", "Proxy", "Redirect"], var.connection_policy)
    error_message = "connection_policy must be one of Default, Proxy, or Redirect."
  }
}

variable "express_vulnerability_assessment_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable the Express Vulnerability Assessment Configuration."
}

variable "transparent_data_encryption_key_vault_key_id" {
  type        = string
  default     = null
  description = "The fully versioned Key Vault Key URL."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = true
  description = "Whether public network access is allowed for this server."
}

variable "outbound_network_restriction_enabled" {
  type        = bool
  default     = false
  description = "Whether outbound network traffic is restricted for this server."
}

variable "primary_user_assigned_identity_id" {
  type        = string
  default     = null
  description = " Specifies the primary user managed identity id."

  validation {
    condition = (
      var.identity_ids == null ||
      var.primary_user_assigned_identity_id != null
    )
    error_message = "primary_user_assigned_identity_id must be provided when identity_ids is set."
  }
}

variable "minimum_tls_version" {
  type        = string
  default     = "1.2"
  description = "The Minimum TLS Version for all SQL Database and SQL Data Warehouse databases associated with the server."
}

variable "azuread_administrator" {
  type = object({
    login_username              = string
    object_id                   = string
    tenant_id                   = optional(string)
    azuread_authentication_only = optional(bool)
  })
  default     = null
  description = "Enable Azure AD-only authentication for the server administrator."
}

variable "identity_ids" {
  type        = list(string)
  default     = null
  description = "List of user managed identity IDs for MSSQL DB."
}

variable "encryption" {
  type        = bool
  default     = false
  description = "Enable or disable encryption for MSSQL DB."
}

variable "secondary_sql_server_location" {
  type        = string
  default     = null
  description = "Specifies the supported Azure location to create secondary sql server resource."
}

##------------------------------------------------------------
## Extended Auditing Policy
##-----------------------------------------------------------

variable "enable_sql_server_extended_auditing_policy" {
  type        = bool
  default     = false
  description = "Manages Extended Audit policy for SQL servers."
}

variable "storage_account_blob_endpoint" {
  type        = string
  default     = null
  description = "The endpoint URL for blob storage in the primary location."
}

variable "storage_account_access_key" {
  type        = string
  default     = null
  description = "The primary access key for the storage account."
}

variable "storage_account_access_key_is_secondary" {
  type        = bool
  default     = false
  description = "Specifies whether the provided storage account access key is the secondary key."
}

variable "log_retention_days" {
  type        = string
  default     = "30"
  description = "Specifies the number of days to keep in the Threat Detection audit logs"
}

variable "storage_account_subscription_id" {
  type        = string
  default     = null
  description = "The ID of the Subscription containing the Storage Account."
}

variable "predicate_expression" {
  type        = string
  default     = null
  description = "Specifies the WHERE clause condition used when creating an audit."
}

variable "audit_actions_and_groups" {
  type        = list(string)
  default     = null
  description = "List of audit action groups and individual actions to be audited."
}

variable "enable_log_monitoring" {
  type        = bool
  default     = false
  description = "Enable audit events to Azure Monitor?."
}

##------------------------------------------------------
## Database
##------------------------------------------------------

variable "enable_mssql_db" {
  type        = bool
  default     = false
  description = "Enable or disable creation of the MSSQL Database."
}

variable "auto_pause_delay_in_minutes" {
  type        = number
  default     = null
  description = "Time in minutes after which the database is automatically paused. Use -1 to disable auto-pause. Only applicable for Serverless databases."
}

variable "transparent_data_encryption_enabled" {
  type        = bool
  default     = true
  description = "If true, Transparent Data Encryption (TDE) is enabled on the database."
}

variable "create_mode" {
  type        = string
  default     = null
  description = "The create mode of the database. Possible values are Copy, Default, OnlineSecondary, PointInTimeRestore, Recovery, Restore, RestoreExternalBackup, RestoreExternalBackupSecondary, RestoreLongTermRetentionBackup and Secondary."
}

variable "creation_source_database_id" {
  type        = string
  default     = null
  description = "The ID of the source database from which to create the new database."
}

variable "collation" {
  type        = string
  default     = null
  description = "Specifies the collation of the database."
}

variable "elastic_pool_id" {
  type        = string
  default     = null
  description = "Specifies the ID of the elastic pool containing this database."
}

variable "geo_backup_enabled" {
  type        = bool
  default     = true
  description = "A boolean that specifies if the Geo Backup Policy is enabled."
}

variable "ledger_enabled" {
  type        = bool
  default     = false
  description = "A boolean that specifies if this is a ledger database."
}

variable "min_capacity" {
  type        = number
  default     = null
  description = "Minimal capacity that database will always have allocated, if not paused. This property is only settable for Serverless databases."
}

variable "restore_point_in_time" {
  type        = string
  default     = null
  description = "Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database. This property is only settable for create_mode= PointInTimeRestore databases."
}

variable "recover_database_id" {
  type        = string
  default     = null
  description = "The ID of the database to be recovered. This property is only applicable when the create_mode is Recovery."
}

variable "database_max_size_gb" {
  type        = number
  default     = 2
  description = "The Maximum size of database."
}

variable "recovery_point_id" {
  type        = string
  default     = null
  description = "The ID of the Recovery Services Recovery Point Id to be restored. This property is only applicable when the create_mode is Recovery."
}

variable "restore_dropped_database_id" {
  type        = string
  default     = null
  description = "The ID of the database to be restored. This property is only applicable when the create_mode is Restore."
}

variable "restore_long_term_retention_backup_id" {
  type        = string
  default     = null
  description = "The ID of the long term retention backup to be restored. This property is only applicable when the create_mode is RestoreLongTermRetentionBackup."
}

variable "read_replica_count" {
  type        = number
  default     = null
  description = "The number of readonly secondary replicas associated with the database to which readonly application intent connections may be routed. This property is only settable for Hyperscale edition databases."
}

variable "read_scale" {
  type        = bool
  default     = false
  description = "If enabled, connections that have application intent set to readonly in their connection string may be routed to a readonly secondary replica. This property is only settable for Premium and Business Critical databases."
}

variable "sample_name" {
  type        = string
  default     = null
  description = "Specifies the name of the sample schema to apply when creating this database. Possible value is AdventureWorksLT."
}

variable "database_sku_name" {
  type        = string
  default     = null
  description = "Specifies the name of the SKU used by the database. For example, GP_S_Gen5_2,HS_Gen4_1,BC_Gen5_2, ElasticPool, Basic,S0, P2 ,DW100c, DS100."
}

variable "storage_account_type" {
  type        = string
  default     = null
  description = "Specifies the storage account type used to store backups for this database. Possible values are Geo, GeoZone, Local and Zone. Defaults to Geo."
}

variable "transparent_data_encryption_key_automatic_rotation_enabled" {
  type        = bool
  default     = false
  description = "Boolean flag to specify whether TDE automatically rotates the encryption Key to latest version or not."
}

variable "secondary_type" {
  type        = string
  default     = null
  description = "How do you want your replica to be made? Valid values include Geo, Named and Standby. Defaults to Geo."
}

variable "import" {
  type = object({
    storage_uri                  = string
    storage_key                  = string
    storage_key_type             = string
    administrator_login          = string
    administrator_login_password = string
    authentication_type          = string
    storage_account_id           = optional(string)
  })
  default     = null
  description = "Optional import configuration for importing a .bacpac file into the database."
}

variable "threat_detection_policy" {
  type = object({
    state                      = optional(string)
    disabled_alerts            = optional(list(string))
    email_account_admins       = optional(bool)
    email_addresses            = optional(list(string))
    retention_days             = optional(number)
    storage_account_access_key = optional(string)
    storage_endpoint           = optional(string)
  })
  default     = null
  description = "Optional SQL Database Threat Detection policy configuration."
}

variable "long_term_retention_policy" {
  type = object({
    weekly_retention          = optional(string)
    monthly_retention         = optional(string)
    yearly_retention          = optional(string)
    week_of_year              = optional(number)
    immutable_backups_enabled = optional(bool)
  })
  default     = null
  description = "Optional long-term retention (LTR) policy for the SQL database."
}

variable "short_term_retention_policy" {
  type = object({
    retention_days           = number
    backup_interval_in_hours = optional(number, 24)
  })
  default     = null
  description = "Optional short-term retention (STR) policy for the SQL database."
}

variable "enable_database_extended_auditing_policy" {
  type        = bool
  default     = false
  description = "Manages Extended Audit policy for SQL database."
}

##---------------------------------------------------
## MSSQL Server Vulnerability & Alert 
##---------------------------------------------------

variable "enable_security_alert_policy" {
  type        = bool
  default     = false
  description = "Enable or disable creation of the MSSQL Databases Security Alert Policy."
}

variable "state" {
  type        = string
  default     = null
  description = "Specifies the state of the policy. Possible Values 'Enabled', 'Disabled'."
}

variable "email_account_admins" {
  type        = bool
  default     = false
  description = "Are the alerts sent to the account administrators?."
}

variable "email_addresses_for_alerts" {
  type        = list(any)
  default     = []
  description = "A list of email addresses which alerts should be sent to."
}

variable "threat_detection_audit_logs_retention_days" {
  type        = number
  default     = 0
  description = "Specifies the number of days to keep in the Threat Detection audit logs."
}

variable "disabled_alerts" {
  type        = list(any)
  default     = []
  description = "Specifies an array of alerts that are disabled. Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action."
}

variable "enable_vulnerability_assessment" {
  type        = bool
  default     = false
  description = "Manages the Vulnerability Assessment for a MS SQL Server."
}

variable "storage_container_path" {
  type        = string
  default     = null
  description = "The Path of the Container inside Storage Account for Vulnerability Assessment."
}

variable "storage_container_sas_key" {
  type        = string
  default     = null
  description = "The SAS Key for the Storage Container for Vulnerability Assessment."
}

variable "recurring_scans" {
  type = map(object({
    enabled                   = optional(bool)
    emails                    = optional(list(any))
    email_subscription_admins = optional(bool)
  }))
  default     = {}
  description = "List of Recurring Scans for Vulnerability Assessment."
}

variable "enable_vulnerability_assessment_rule_baseline" {
  type        = bool
  default     = false
  description = "Vulnerability Assessment rule baselines with justification for each suppressed rule."
}

variable "rule_id" {
  type        = string
  default     = null
  description = " The vulnerability assessment rule ID. Changing this forces a new resource to be created."
}

variable "baseline_result" {
  type        = list(any)
  default     = []
  description = "Baseline result for the database. Must be a list representing the baseline metrics."
}

variable "baseline_name" {
  type        = string
  default     = null
  description = "The name of the vulnerability assessment rule baseline."
}

##--------------------------------------------------------
## Firewall
##--------------------------------------------------------

variable "enable_firewall_rules" {
  type        = bool
  default     = false
  description = "Enable or Disable creation of the firewall rules of the MSSQL Server."
}

variable "enable_failover_firewall_rules" {
  type        = bool
  default     = false
  description = "Enable or Disable creation of the firewall rules for failover server."
}

variable "firewall_rules" {
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {
    "name" = {
      start_ip_address = null
      end_ip_address   = null
    }
  }
  description = "The Firewall Rules of the MSSQL Server."
}

variable "mssql_outbound_firewall_rule_fqdns" {
  type        = map(any)
  default     = null
  description = "The fully qualified domain names of the resources to be accessed via server"
}

##---------------------------------------------------------
## DNS, TDE
##---------------------------------------------------------

variable "enable_dns_alias" {
  type        = bool
  default     = false
  description = "Enable or Disable creation of dns alias of server."
}

variable "enable_transparent_data_encryption" {
  type        = bool
  default     = false
  description = "Enable or Disable creation of Transparent data encryption in Databases."
}

variable "managed_hsm_key_id" {
  type        = string
  default     = null
  description = "Managed HSM key ID for the transparent data encryption."
}

variable "auto_rotation_enabled" {
  type        = bool
  default     = false
  description = "Auto rotation should be Enable or Disable."
}


variable "sqlserver_name" {
  type        = string
  default     = ""
  description = "SQL server Name."
}
##---------------------------------------------------
##JOB
##---------------------------------------------------

variable "enable_job_agent" {
  type        = bool
  default     = false
  description = "Enable or Disable creation of job agent of Database."
}

variable "ja_sku" {
  type        = string
  default     = null
  description = "The name of the SKU to use for this Elastic Job Agent. Possible values are JA100, JA200, JA400, and JA800."
}

variable "job_credentials" {
  type = map(object({
    username            = string
    password            = optional(string)
    password_wo         = optional(string)
    password_wo_version = optional(number)
  }))
  default     = {}
  description = "Map of Job Credentials to be created for a Job."
}

variable "job_target_group" {
  type = map(object({
    membership_type   = string       # "All" or "Specific"
    databases         = list(string) # List of DB names
    job_credential_id = string       # Optional
    elastic_pool_name = string       # Optional
  }))
  default     = {}
  description = "Map of Target Group to be created for a Job."
}

variable "job" {
  type = map(object({
    description = optional(string)
  }))
  default     = {}
  description = "Map of Jobs for Databases."
}

variable "job_schedule" {
  type = map(object({
    schedule_type       = string
    schedule_enable     = optional(string)
    schedule_end_time   = optional(string) # RFC3339 format.
    schedule_interval   = optional(string) # ISO8601 duration format.
    schedule_start_time = optional(string) # RFC3339 format.
  }))
  default     = {}
  description = "Map of Job Schedule to be created for a Job."
}

variable "job_step" {
  type = map(object({
    job_step_index                    = number #  This value must be greater than or equal to 1 and less than or equal to the number of job steps in the Elastic Job.
    sql_script                        = string # Required T-SQL Script.
    initial_retry_interval_seconds    = optional(number)
    maximum_retry_interval_seconds    = optional(number)
    retry_attempts                    = optional(number)
    retry_interval_backoff_multiplier = optional(number)
    timeout_seconds                   = optional(number)
    output_targets = optional(list(object({
      mssql_database_id = string
      table_name        = string
      schema_name       = optional(string)
      job_credential_id = optional(string)
    })), [])
  }))
  default     = {}
  description = "Map of Job Steps to be created for a Job."
}

variable "initialize_sql_script_execution" {
  type        = bool
  default     = false
  description = "Allow/deny to Create and initialize a Microsoft SQL Server database."
}

variable "sqldb_init_script_file" {
  type        = string
  default     = ""
  description = "SQL Script file name to create and initialize the database."
}

##--------------------------------------------------------------------------
## Failover Group
##--------------------------------------------------------------------------

variable "enable_failover_group" {
  type        = bool
  default     = false
  description = "Create a failover group of databases on a collection of Azure SQL servers."
}

variable "readonly_endpoint_failover_policy_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable the read-only endpoint failover policy for the Azure SQL database."
}

variable "read_write_endpoint_failover_policy" {
  type = object({
    mode          = string
    grace_minutes = optional(number)
  })
  default     = null
  description = "Settings for read-write endpoint failover policy."
}

##-------------------------------------------------
## Private Endpoint
##-------------------------------------------------

variable "enable_private_endpoint" {
  default     = false
  type        = bool
  description = "Manages a Private Endpoint to SQL database."
}

variable "private_endpoint_subnet_id" {
  type        = string
  default     = null
  description = "Subnet ID for private endpoint."
}

##------------------------------------------------------
## ElasticPool
##-------------------------------------------------------

variable "enable_elasticpool" {
  type        = bool
  default     = false
  description = "Enable or Disable creation of ElasticPool."
}

variable "maintenance_configuration_name" {
  type        = string
  default     = null
  description = "Maintenance Configuration name for the elasticpool."
}

variable "elasticpool_max_size_gb" {
  type        = number
  default     = 1
  description = "Maximum Storage Size of ElasticPool in GB."
}

variable "max_size_bytes" {
  type        = number
  default     = null
  description = "Maximum Storage Size of ElasticPool in Bytes."
}

variable "enclave_type" {
  type        = string
  default     = null
  description = "Specifies the type of enclave to be used by the elastic pool."
}

variable "zone_redundant" {
  type        = string
  default     = null
  description = "Whether or not this elastic pool is zone redundant. "
}

variable "license_type" {
  type        = string
  default     = null
  description = "Specifies the license type applied to this database."
}

variable "sku" {
  type = object({
    name     = string
    tier     = string
    capacity = number
    family   = optional(string)
  })
  default     = null
  description = "ElasticPool Sku Configuration."
}

variable "per_database_settings" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default     = null
  description = "Min & Max vCores/DTU per Database."
}

##-----------------------------------------------------------------------------
## Diagnostic Setting Variables
##-----------------------------------------------------------------------------

variable "enable_diagnostic" {
  type        = bool
  default     = false
  description = "Enable diagnostic settings for Linux Web App."
}

variable "storage_account_id" {
  type        = string
  default     = null
  description = "Storage Account ID for diagnostic logs (optional)."
}

variable "log_analytics_workspace_id" {
  type        = string
  default     = null
  description = "Log Analytics Workspace ID for diagnostic logs."
}

variable "eventhub_name" {
  type        = string
  default     = null
  description = "Eventhub Name to pass it to destination details of diagnosys setting of NSG."
}

variable "eventhub_authorization_rule_id" {
  type        = string
  default     = null
  description = "Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG."
}

variable "log_enabled" {
  type        = bool
  default     = true
  description = "Enable log categories for diagnostic settings."
}

variable "metric_enabled" {
  type        = bool
  default     = true
  description = "Enable metrics for diagnostic settings."
}

##-----------------------------------------------------
## Key Vault Key
##-----------------------------------------------------

variable "key_expiration_date" {
  description = "The expiration date for the Key Vault key"
  type        = string
  default     = "2028-12-31T23:59:59Z" # ISO 8601 format
}

variable "key_type" {
  description = "The type of the key to create in Key Vault."
  type        = string
  default     = "RSA-HSM"
}

variable "key_size" {
  description = "The size of the RSA key in bits."
  type        = number
  default     = 2048
}

variable "key_permissions" {
  type        = list(string)
  default     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  description = "List of key permissions for the Key Vault key."
}

variable "rotation_policy_config" {
  type = object({
    enabled              = bool
    time_before_expiry   = optional(string, "P30D")
    expire_after         = optional(string, "P90D")
    notify_before_expiry = optional(string, "P29D")
  })
  default = {
    enabled              = false
    time_before_expiry   = "P30D"
    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
  description = "Rotation policy configuration for Key Vault keys."
}

variable "key_vault_id" {
  type        = string
  default     = null
  description = "Azure Key Vault ID for integration."
}

variable "private_dns_zone_ids" {
  type        = string
  default     = null
  description = "Id of the private DNS Zone"
}

##------------------------------------------------------------------
## Microsoft Support Auditing Policy & virtual Network Rule
##------------------------------------------------------------------

variable "enable_microsoft_support_auditing_policy" {
  type        = bool
  default     = false
  description = "Enable or Disable creation of microsoft support auditing policy."
}

variable "enable_virtual_network_rule" {
  type        = bool
  default     = false
  description = "Enable or Disable creation of Virtual Network Rule."
}

variable "vnet_rule_subnet_id" {
  type        = string
  default     = null
  description = "The ID of the subnet from which the SQL server will accept communications(Must be Microsoft.SQL if ignore_missing_vnet_service_endpoint is true)."
}

variable "ignore_missing_vnet_service_endpoint" {
  type        = bool
  default     = false
  description = "Create the virtual network rule before the subnet has the virtual network service endpoint enabled."
}