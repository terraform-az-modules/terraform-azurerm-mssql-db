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
  description = "Enable or disable creation of all MSSQL resources."
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
  default     = "https://github.com/terraform-az-modules/terraform-azurerm-mssql-db"
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
  default     = false
  description = "Whether public network access is allowed for this server."
}

variable "outbound_network_restriction_enabled" {
  type        = bool
  default     = false
  description = "Whether outbound network traffic is restricted for this server."
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

variable "enable_system_assigned_identity" {
  type        = bool
  default     = true
  description = "Enable system-assigned managed identity on the SQL server."
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
  type        = number
  default     = 7
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
variable "databases" {
  description = "Map of MSSQL databases to create on the primary server, keyed by database name."
  type = map(object({
    auto_pause_delay_in_minutes                                = optional(number)
    create_mode                                                = optional(string)
    creation_source_database_id                                = optional(string)
    collation                                                  = optional(string)
    elastic_pool_id                                            = optional(string)
    enclave_type                                               = optional(string)
    geo_backup_enabled                                         = optional(bool)
    maintenance_configuration_name                             = optional(string)
    ledger_enabled                                             = optional(bool)
    license_type                                               = optional(string)
    max_size_gb                                                = optional(number)
    min_capacity                                               = optional(number)
    restore_point_in_time                                      = optional(string)
    recover_database_id                                        = optional(string)
    recovery_point_id                                          = optional(string)
    restore_dropped_database_id                                = optional(string)
    restore_long_term_retention_backup_id                      = optional(string)
    read_replica_count                                         = optional(number)
    read_scale                                                 = optional(bool)
    sample_name                                                = optional(string)
    sku_name                                                   = optional(string)
    storage_account_type                                       = optional(string)
    transparent_data_encryption_enabled                        = optional(bool)
    transparent_data_encryption_key_vault_key_id               = optional(string)
    transparent_data_encryption_key_automatic_rotation_enabled = optional(bool)
    zone_redundant                                             = optional(bool)
    secondary_type                                             = optional(string)
    use_elasticpool                                            = optional(bool, false)
    tags                                                       = optional(map(string), {})

    import = optional(object({
      storage_uri                  = string
      storage_key                  = optional(string)
      storage_key_type             = optional(string)
      administrator_login          = string
      administrator_login_password = optional(string)
      authentication_type          = string
      storage_account_id           = optional(string)
    }))

    threat_detection_policy = optional(object({
      state                      = optional(string)
      disabled_alerts            = optional(list(string))
      email_account_admins       = optional(bool)
      email_addresses            = optional(list(string))
      retention_days             = optional(number)
      storage_account_access_key = optional(string)
      storage_endpoint           = optional(string)
    }))

    long_term_retention_policy = optional(object({
      weekly_retention          = optional(string)
      monthly_retention         = optional(string)
      yearly_retention          = optional(string)
      week_of_year              = optional(number)
      immutable_backups_enabled = optional(bool)
    }))

    short_term_retention_policy = optional(object({
      retention_days           = optional(number)
      backup_interval_in_hours = optional(number)
    }))
  }))
  default = {}
}

variable "enable_mssql_db" {
  type        = bool
  default     = false
  description = "Enable or disable creation of the MSSQL Database."
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
    output_target = optional(map(object({
      database_key      = string
      table_name        = string
      job_credential_id = optional(string)
      schema_name       = optional(string)
    })))
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

variable "job_agent_database_key" {
  type        = string
  default     = null
  description = "Key of the database in var.databases to host the SQL Job Agent."
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

variable "private_dns_zone_ids" {
  description = "List of Private DNS Zone IDs to associate with the private endpoint."
  type        = list(string)
  default     = []
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
  type        = bool
  default     = false
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
  description = "Enable diagnostic settings for MSSQL Database."
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
  description = "Eventhub name to pass to destination details of diagnostic settings."
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