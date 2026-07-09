## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password\_length | Length of the randomly generated admin password, if not provided. | `number` | `16` | no |
| administrator\_login | The administrator login name for the new SQL Server. | `string` | `null` | no |
| administrator\_login\_password | The password associated with the admin\_username user. | `string` | `null` | no |
| administrator\_login\_password\_wo | Write-only administrator password for the server (not stored in Terraform state). | `string` | `null` | no |
| administrator\_login\_password\_wo\_version | The version of the Write-only administrator password for the server. | `string` | `null` | no |
| audit\_actions\_and\_groups | List of audit action groups and individual actions to be audited. | `list(string)` | `null` | no |
| auto\_rotation\_enabled | Auto rotation should be Enable or Disable. | `bool` | `false` | no |
| azuread\_administrator | Enable Azure AD-only authentication for the server administrator. | <pre>object({<br>    login_username              = string<br>    object_id                   = string<br>    tenant_id                   = optional(string)<br>    azuread_authentication_only = optional(bool)<br>  })</pre> | `null` | no |
| baseline\_name | The name of the vulnerability assessment rule baseline. | `string` | `null` | no |
| baseline\_result | Baseline result for the database. Must be a list representing the baseline metrics. | `list(any)` | `[]` | no |
| connection\_policy | The connection policy the server will use. | `string` | `"Default"` | no |
| custom\_name | Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.<br><br>- If true, the keyword is prepended: "vnet-core-dev".<br>- If false, the keyword is appended: "core-dev-vnet".<br><br>This helps maintain naming consistency based on organizational preferences. | `string` | `null` | no |
| databases | Map of MSSQL databases to create on the primary server, keyed by database name. | <pre>map(object({<br>    auto_pause_delay_in_minutes                                = optional(number)<br>    create_mode                                                = optional(string)<br>    creation_source_database_id                                = optional(string)<br>    collation                                                  = optional(string)<br>    elastic_pool_id                                            = optional(string)<br>    enclave_type                                               = optional(string)<br>    geo_backup_enabled                                         = optional(bool)<br>    maintenance_configuration_name                             = optional(string)<br>    ledger_enabled                                             = optional(bool)<br>    license_type                                               = optional(string)<br>    max_size_gb                                                = optional(number)<br>    min_capacity                                               = optional(number)<br>    restore_point_in_time                                      = optional(string)<br>    recover_database_id                                        = optional(string)<br>    recovery_point_id                                          = optional(string)<br>    restore_dropped_database_id                                = optional(string)<br>    restore_long_term_retention_backup_id                      = optional(string)<br>    read_replica_count                                         = optional(number)<br>    read_scale                                                 = optional(bool)<br>    sample_name                                                = optional(string)<br>    sku_name                                                   = optional(string)<br>    storage_account_type                                       = optional(string)<br>    transparent_data_encryption_enabled                        = optional(bool)<br>    transparent_data_encryption_key_vault_key_id               = optional(string)<br>    transparent_data_encryption_key_automatic_rotation_enabled = optional(bool)<br>    zone_redundant                                             = optional(bool)<br>    secondary_type                                             = optional(string)<br>    use_elasticpool                                            = optional(bool, false)<br>    tags                                                       = optional(map(string), {})<br><br>    import = optional(object({<br>      storage_uri                  = string<br>      storage_key                  = optional(string)<br>      storage_key_type             = optional(string)<br>      administrator_login          = string<br>      administrator_login_password = optional(string)<br>      authentication_type          = string<br>      storage_account_id           = optional(string)<br>    }))<br><br>    threat_detection_policy = optional(object({<br>      state                      = optional(string)<br>      disabled_alerts            = optional(list(string))<br>      email_account_admins       = optional(bool)<br>      email_addresses            = optional(list(string))<br>      retention_days             = optional(number)<br>      storage_account_access_key = optional(string)<br>      storage_endpoint           = optional(string)<br>    }))<br><br>    long_term_retention_policy = optional(object({<br>      weekly_retention          = optional(string)<br>      monthly_retention         = optional(string)<br>      yearly_retention          = optional(string)<br>      week_of_year              = optional(number)<br>      immutable_backups_enabled = optional(bool)<br>    }))<br><br>    short_term_retention_policy = optional(object({<br>      retention_days           = optional(number)<br>      backup_interval_in_hours = optional(number)<br>    }))<br>  }))</pre> | `{}` | no |
| deployment\_mode | Deployment mode identifier (e.g., blue/green, canary). | `string` | `"terraform"` | no |
| disabled\_alerts | Specifies an array of alerts that are disabled. Allowed values are: Sql\_Injection, Sql\_Injection\_Vulnerability, Access\_Anomaly, Data\_Exfiltration, Unsafe\_Action. | `list(any)` | `[]` | no |
| elasticpool\_max\_size\_gb | Maximum Storage Size of ElasticPool in GB. | `number` | `1` | no |
| email\_account\_admins | Are the alerts sent to the account administrators?. | `bool` | `false` | no |
| email\_addresses\_for\_alerts | A list of email addresses which alerts should be sent to. | `list(any)` | `[]` | no |
| enable\_database\_extended\_auditing\_policy | Manages Extended Audit policy for SQL database. | `bool` | `false` | no |
| enable\_diagnostic | Enable diagnostic settings for MSSQL Database. | `bool` | `false` | no |
| enable\_dns\_alias | Enable or Disable creation of dns alias of server. | `bool` | `false` | no |
| enable\_elasticpool | Enable or Disable creation of ElasticPool. | `bool` | `false` | no |
| enable\_failover\_firewall\_rules | Enable or Disable creation of the firewall rules for failover server. | `bool` | `false` | no |
| enable\_failover\_group | Create a failover group of databases on a collection of Azure SQL servers. | `bool` | `false` | no |
| enable\_firewall\_rules | Enable or Disable creation of the firewall rules of the MSSQL Server. | `bool` | `false` | no |
| enable\_job\_agent | Enable or Disable creation of job agent of Database. | `bool` | `false` | no |
| enable\_log\_monitoring | Enable audit events to Azure Monitor?. | `bool` | `false` | no |
| enable\_microsoft\_support\_auditing\_policy | Enable or Disable creation of microsoft support auditing policy. | `bool` | `false` | no |
| enable\_mssql\_db | Enable or disable creation of the MSSQL Database. | `bool` | `false` | no |
| enable\_private\_endpoint | Manages a Private Endpoint to SQL database. | `bool` | `false` | no |
| enable\_security\_alert\_policy | Enable or disable creation of the MSSQL Databases Security Alert Policy. | `bool` | `false` | no |
| enable\_sql\_server\_extended\_auditing\_policy | Manages Extended Audit policy for SQL servers. | `bool` | `false` | no |
| enable\_system\_assigned\_identity | Enable system-assigned managed identity on the SQL server. | `bool` | `true` | no |
| enable\_transparent\_data\_encryption | Enable or Disable creation of Transparent data encryption in Databases. | `bool` | `false` | no |
| enable\_virtual\_network\_rule | Enable or Disable creation of Virtual Network Rule. | `bool` | `false` | no |
| enable\_vulnerability\_assessment | Manages the Vulnerability Assessment for a MS SQL Server. | `bool` | `false` | no |
| enable\_vulnerability\_assessment\_rule\_baseline | Vulnerability Assessment rule baselines with justification for each suppressed rule. | `bool` | `false` | no |
| enabled | Enable or disable creation of all MSSQL resources. | `bool` | `true` | no |
| enclave\_type | Specifies the type of enclave to be used by the elastic pool. | `string` | `null` | no |
| encryption | Enable or disable encryption for MSSQL DB. | `bool` | `false` | no |
| environment | Deployment environment (e.g., dev, stage, prod). | `string` | `null` | no |
| eventhub\_authorization\_rule\_id | Eventhub authorization rule id to pass it to destination details of diagnosys setting of NSG. | `string` | `null` | no |
| eventhub\_name | Eventhub name to pass to destination details of diagnostic settings. | `string` | `null` | no |
| express\_vulnerability\_assessment\_enabled | Whether to enable the Express Vulnerability Assessment Configuration. | `bool` | `false` | no |
| extra\_tags | Additional tags to apply to all resources. | `map(string)` | `{}` | no |
| firewall\_rules | The Firewall Rules of the MSSQL Server. | <pre>map(object({<br>    start_ip_address = string<br>    end_ip_address   = string<br>  }))</pre> | <pre>{<br>  "name": {<br>    "end_ip_address": null,<br>    "start_ip_address": null<br>  }<br>}</pre> | no |
| ignore\_missing\_vnet\_service\_endpoint | Create the virtual network rule before the subnet has the virtual network service endpoint enabled. | `bool` | `false` | no |
| initialize\_sql\_script\_execution | Allow/deny to Create and initialize a Microsoft SQL Server database. | `bool` | `false` | no |
| ja\_sku | The name of the SKU to use for this Elastic Job Agent. Possible values are JA100, JA200, JA400, and JA800. | `string` | `null` | no |
| job | Map of Jobs for Databases. | <pre>map(object({<br>    description = optional(string)<br>  }))</pre> | `{}` | no |
| job\_agent\_database\_key | Key of the database in var.databases to host the SQL Job Agent. | `string` | `null` | no |
| job\_credentials | Map of Job Credentials to be created for a Job. | <pre>map(object({<br>    username            = string<br>    password            = optional(string)<br>    password_wo         = optional(string)<br>    password_wo_version = optional(number)<br>  }))</pre> | `{}` | no |
| job\_schedule | Map of Job Schedule to be created for a Job. | <pre>map(object({<br>    schedule_type       = string<br>    schedule_enable     = optional(string)<br>    schedule_end_time   = optional(string) # RFC3339 format.<br>    schedule_interval   = optional(string) # ISO8601 duration format.<br>    schedule_start_time = optional(string) # RFC3339 format.<br>  }))</pre> | `{}` | no |
| job\_step | Map of Job Steps to be created for a Job. | <pre>map(object({<br>    job_step_index                    = number #  This value must be greater than or equal to 1 and less than or equal to the number of job steps in the Elastic Job.<br>    sql_script                        = string # Required T-SQL Script.<br>    initial_retry_interval_seconds    = optional(number)<br>    maximum_retry_interval_seconds    = optional(number)<br>    retry_attempts                    = optional(number)<br>    retry_interval_backoff_multiplier = optional(number)<br>    timeout_seconds                   = optional(number)<br>    output_target = optional(map(object({<br>      database_key      = string<br>      table_name        = string<br>      job_credential_id = optional(string)<br>      schema_name       = optional(string)<br>    })))<br>  }))</pre> | `{}` | no |
| job\_target\_group | Map of Target Group to be created for a Job. | <pre>map(object({<br>    membership_type   = string       # "All" or "Specific"<br>    databases         = list(string) # List of DB names<br>    job_credential_id = string       # Optional<br>    elastic_pool_name = string       # Optional<br>  }))</pre> | `{}` | no |
| key\_expiration\_date | The expiration date for the Key Vault key | `string` | `"2028-12-31T23:59:59Z"` | no |
| key\_permissions | List of key permissions for the Key Vault key. | `list(string)` | <pre>[<br>  "decrypt",<br>  "encrypt",<br>  "sign",<br>  "unwrapKey",<br>  "verify",<br>  "wrapKey"<br>]</pre> | no |
| key\_size | The size of the RSA key in bits. | `number` | `2048` | no |
| key\_type | The type of the key to create in Key Vault. | `string` | `"RSA-HSM"` | no |
| key\_vault\_id | Azure Key Vault ID for integration. | `string` | `null` | no |
| label\_order | Order of labels to be used in naming/tagging. | `list(string)` | <pre>[<br>  "name",<br>  "environment",<br>  "location"<br>]</pre> | no |
| license\_type | Specifies the license type applied to this database. | `string` | `null` | no |
| location | Azure region where resources will be deployed. | `string` | `null` | no |
| log\_analytics\_workspace\_id | Log Analytics Workspace ID for diagnostic logs. | `string` | `null` | no |
| log\_enabled | Enable log categories for diagnostic settings. | `bool` | `true` | no |
| log\_retention\_days | Specifies the number of days to keep in the Threat Detection audit logs | `number` | `7` | no |
| maintenance\_configuration\_name | Maintenance Configuration name for the elasticpool. | `string` | `null` | no |
| managed\_hsm\_key\_id | Managed HSM key ID for the transparent data encryption. | `string` | `null` | no |
| managedby | Tag to indicate the tool or team managing the resources. | `string` | `"terraform"` | no |
| max\_size\_bytes | Maximum Storage Size of ElasticPool in Bytes. | `number` | `null` | no |
| metric\_enabled | Enable metrics for diagnostic settings. | `bool` | `true` | no |
| min\_lower | Minimum number of lowercase letters in the generated password. | `number` | `2` | no |
| min\_numeric | Minimum number of numeric characters in the generated password. | `number` | `4` | no |
| min\_upper | Minimum number of uppercase letters in the generated password. | `number` | `4` | no |
| minimum\_tls\_version | The Minimum TLS Version for all SQL Database and SQL Data Warehouse databases associated with the server. | `string` | `"1.2"` | no |
| mssql\_outbound\_firewall\_rule\_fqdns | The fully qualified domain names of the resources to be accessed via server | `map(any)` | `null` | no |
| name | Base name for resources. | `string` | `null` | no |
| outbound\_network\_restriction\_enabled | Whether outbound network traffic is restricted for this server. | `bool` | `false` | no |
| per\_database\_settings | Min & Max vCores/DTU per Database. | <pre>object({<br>    min_capacity = number<br>    max_capacity = number<br>  })</pre> | `null` | no |
| predicate\_expression | Specifies the WHERE clause condition used when creating an audit. | `string` | `null` | no |
| private\_dns\_zone\_ids | List of Private DNS Zone IDs to associate with the private endpoint. | `list(string)` | `[]` | no |
| private\_endpoint\_subnet\_id | Subnet ID for private endpoint. | `string` | `null` | no |
| public\_network\_access\_enabled | Whether public network access is allowed for this server. | `bool` | `false` | no |
| read\_write\_endpoint\_failover\_policy | Settings for read-write endpoint failover policy. | <pre>object({<br>    mode          = string<br>    grace_minutes = optional(number)<br>  })</pre> | `null` | no |
| readonly\_endpoint\_failover\_policy\_enabled | Enable or disable the read-only endpoint failover policy for the Azure SQL database. | `bool` | `false` | no |
| recurring\_scans | List of Recurring Scans for Vulnerability Assessment. | <pre>map(object({<br>    enabled                   = optional(bool)<br>    emails                    = optional(list(any))<br>    email_subscription_admins = optional(bool)<br>  }))</pre> | `{}` | no |
| repository | Repository URL or identifier for traceability. | `string` | `"https://github.com/terraform-az-modules/terraform-azurerm-mssql-db"` | no |
| resource\_group\_name | Name of the resource group where resources will be deployed. | `string` | `null` | no |
| resource\_position\_prefix | If true, prefixes resource names instead of suffixing. | `bool` | `false` | no |
| rotation\_policy\_config | Rotation policy configuration for Key Vault keys. | <pre>object({<br>    enabled              = bool<br>    time_before_expiry   = optional(string, "P30D")<br>    expire_after         = optional(string, "P90D")<br>    notify_before_expiry = optional(string, "P29D")<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "expire_after": "P90D",<br>  "notify_before_expiry": "P29D",<br>  "time_before_expiry": "P30D"<br>}</pre> | no |
| rule\_id | The vulnerability assessment rule ID. Changing this forces a new resource to be created. | `string` | `null` | no |
| secondary\_sql\_server\_location | Specifies the supported Azure location to create secondary sql server resource. | `string` | `null` | no |
| sku | ElasticPool Sku Configuration. | <pre>object({<br>    name     = string<br>    tier     = string<br>    capacity = number<br>    family   = optional(string)<br>  })</pre> | `null` | no |
| special | Whether to include special characters in the generated password. | `bool` | `false` | no |
| sql\_server\_version | The version for the new server. Valid values are: 2.0 (for v11 server) and 12.0 (for v12 server). | `string` | `null` | no |
| sqldb\_init\_script\_file | SQL Script file name to create and initialize the database. | `string` | `""` | no |
| state | Specifies the state of the policy. Possible Values 'Enabled', 'Disabled'. | `string` | `null` | no |
| storage\_account\_access\_key | The primary access key for the storage account. | `string` | `null` | no |
| storage\_account\_access\_key\_is\_secondary | Specifies whether the provided storage account access key is the secondary key. | `bool` | `false` | no |
| storage\_account\_blob\_endpoint | The endpoint URL for blob storage in the primary location. | `string` | `null` | no |
| storage\_account\_id | Storage Account ID for diagnostic logs (optional). | `string` | `null` | no |
| storage\_account\_subscription\_id | The ID of the Subscription containing the Storage Account. | `string` | `null` | no |
| storage\_container\_path | The Path of the Container inside Storage Account for Vulnerability Assessment. | `string` | `null` | no |
| storage\_container\_sas\_key | The SAS Key for the Storage Container for Vulnerability Assessment. | `string` | `null` | no |
| threat\_detection\_audit\_logs\_retention\_days | Specifies the number of days to keep in the Threat Detection audit logs. | `number` | `0` | no |
| transparent\_data\_encryption\_key\_vault\_key\_id | The fully versioned Key Vault Key URL. | `string` | `null` | no |
| vnet\_rule\_subnet\_id | The ID of the subnet from which the SQL server will accept communications(Must be Microsoft.SQL if ignore\_missing\_vnet\_service\_endpoint is true). | `string` | `null` | no |
| zone\_redundant | Whether or not this elastic pool is zone redundant. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| mssql\_elasticpool\_id | The ID of the MS SQL Elastic Pool. |
| mssql\_elasticpool\_name | The Name of the MS SQL Elastic Pool. |
| mssql\_failover\_group\_id | A failover group of databases on a collection of Azure SQL servers. |
| mssql\_failover\_group\_partner\_server | Map of Azure SQL failover group names to their corresponding partner (secondary) SQL server details. |
| mssql\_server\_job\_agent\_id | The ID of the Elastic Job Agent. |
| mssql\_server\_job\_credential\_id | The ID of the Elastic Job Credential. |
| mssql\_server\_job\_id | The ID of the Elastic Job. |
| mssql\_server\_job\_schedule\_id | The ID of the Elastic Job Schedule. |
| mssql\_server\_job\_step\_id | The ID of the Elastic Job Step. |
| mssql\_server\_job\_target\_group\_id | The ID of the Elastic Job Target Groups. |
| mssql\_server\_outbound\_firewall\_rule\_id | The SQL Outbound Firewall Rule ID. |
| primary\_mssql\_database\_extended\_auditing\_policy\_id | Map of DB extended auditing policy objects keyed by database name. |
| primary\_mssql\_database\_extended\_auditing\_policy\_ids | Map of DB extended auditing policy IDs keyed by database name. |
| primary\_mssql\_database\_vulnerability\_assessment\_rule\_baseline\_ids | Map of DB VA rule baseline IDs keyed by database name. |
| primary\_mssql\_server\_admin\_password | SQL database administrator login password |
| primary\_mssql\_server\_admin\_user | SQL database administrator login id |
| primary\_mssql\_server\_database\_ids | Map of MSSQL database IDs keyed by database name. |
| primary\_mssql\_server\_database\_names | Map of MSSQL database names keyed by database name. |
| primary\_mssql\_server\_dns\_alias\_id | The DNS Alias ID of MSSQL Server. |
| primary\_mssql\_server\_dns\_alias\_record\_set | The fully qualified DNS record for alias of MSSQL Server. |
| primary\_mssql\_server\_firewall\_id | The Primary MSSQL Firewall Rule ID. |
| primary\_mssql\_server\_fqdn | The fully qualified domain name of the primary Azure SQL Server |
| primary\_mssql\_server\_id | The primary Microsoft SQL Server ID |
| primary\_mssql\_server\_microsoft\_support\_auditing\_policy\_id | The ID of the Primary MS SQL Server Microsoft Support Auditing Policy. |
| primary\_mssql\_server\_private\_endpoint | ID of the primary SQL server private endpoint. |
| primary\_mssql\_server\_rdd\_ids | A list of dropped restorable database IDs on the server. |
| primary\_mssql\_server\_security\_alert\_policy\_id | The ID of the Primary MS SQL Server Security Alert Policy. |
| primary\_mssql\_server\_tde\_id | The ID of the MSSQL Server encryption protector. |
| secondary\_mssql\_server\_extended\_auditing\_policy\_id | The ID of the Secondary MS SQL Server Extended Auditing Policy. |
| secondary\_mssql\_server\_firewall\_id | The Secondary MSSQL Firewall Rule ID. |
| secondary\_mssql\_server\_fqdn | The fully qualified domain name of the secondary Azure SQL Server |
| secondary\_mssql\_server\_id | The secondary Microsoft SQL Server ID |
| secondary\_mssql\_server\_microsoft\_support\_auditing\_policy\_id | The ID of the Secondary MS SQL Server Microsoft Support Auditing Policy. |
| secondary\_mssql\_server\_private\_endpoint | ID of the secondary SQL server private endpoint. |
| secondary\_mssql\_server\_rdd\_ids | A list of dropped restorable database IDs on the secondary server. |
| secondary\_mssql\_server\_security\_alert\_policy\_id | The ID of the Secondary MS SQL Server Security Alert Policy. |
| secondary\_mssql\_server\_vulnerability\_assessment\_id | The ID of the Secondary MS SQL Server Vulnerability Assessment. |

