##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------

output "primary_mssql_server_id" {
  description = "The primary Microsoft SQL Server ID"
  value       = azurerm_mssql_server.primary[*].id
}

output "primary_mssql_server_fqdn" {
  description = "The fully qualified domain name of the primary Azure SQL Server"
  value       = azurerm_mssql_server.primary[*].fully_qualified_domain_name
}

output "primary_mssql_server_rdd_ids" {
  description = "A list of dropped restorable database IDs on the server."
  value       = azurerm_mssql_server.primary[*].restorable_dropped_database_ids
}

output "secondary_mssql_server_id" {
  description = "The secondary Microsoft SQL Server ID"
  value       = element(concat(azurerm_mssql_server.secondary[*].id, [""]), 0)
}

output "secondary_mssql_server_fqdn" {
  description = "The fully qualified domain name of the secondary Azure SQL Server"
  value       = element(concat(azurerm_mssql_server.secondary[*].fully_qualified_domain_name, [""]), 0)
}

output "secondary_mssql_server_rdd_ids" {
  description = "A list of dropped restorable database IDs on the  Secondary server."
  value       = azurerm_mssql_server.secondary[*].restorable_dropped_database_ids
}

output "primary_mssql_server_admin_user" {
  description = "SQL database administrator login id"
  value       = azurerm_mssql_server.primary[*].administrator_login
  sensitive   = true
}

output "primary_mssql_server_admin_password" {
  description = "SQL database administrator login password"
  value       = azurerm_mssql_server.primary[*].administrator_login_password
  sensitive   = true
}

output "primary_mssql_server_database_id" {
  description = "The SQL Database ID"
  value       = { for k, v in azurerm_mssql_database.db : k => v.id }
}

output "primary_mssql_server_database_name" {
  description = "The SQL Database Name"
  value       = { for k, v in azurerm_mssql_database.db : k => v.name }
}

output "primary_mssql_server_dns_alias_id" {
  description = "The DNS Alias ID of MSSQL Server."
  value       = try(azurerm_mssql_server_dns_alias.dns[0].id, null)
}

output "primary_mssql_server_dns_alias_record_set" {
  description = "The fully qualified DNS record for alias of MSSQL Server."
  value       = try(azurerm_mssql_server_dns_alias.dns[0].dns_record, null)
}

output "primary_mssql_server_extended_auditing_policy_id" {
  description = "The ID of the Primary MS SQL Server Extended Auditing Policy."
  value       = try(azurerm_mssql_server_extended_auditing_policy.primary[0].id, null)
}

output "secondary_mssql_server_extended_auditing_policy_id" {
  description = "The ID of the Secondary MS SQL Server Extended Auditing Policy."
  value       = azurerm_mssql_server_extended_auditing_policy.secondary[*].id
}

output "primary_mssql_server_microsoft_support_auditing_policy_id" {
  description = "The ID of the Primary MS SQL Server Microsoft Support Auditing Policy."
  value       = azurerm_mssql_server_microsoft_support_auditing_policy.primary[*].id
}

output "secondary_mssql_server_microsoft_support_auditing_policy_id" {
  description = "The ID of the Secondary MS SQL Server Microsoft Support Auditing Policy."
  value       = azurerm_mssql_server_microsoft_support_auditing_policy.secondary[*].id
}

output "primary_mssql_server_security_alert_policy_id" {
  description = "The ID of the Primary MS SQL Server Security Alert Policy."
  value       = azurerm_mssql_server_security_alert_policy.sap_primary[*].id
}

output "primary_mssql_server_tde_id" {
  description = "The ID of the MSSQL Server encryption protector."
  value       = azurerm_mssql_server_transparent_data_encryption.tde[*].id
}

output "primary_mssql_server_vulnerability_assessment_id" {
  description = "The ID of the Primary MS SQL Server Vulnerability Assessment."
  value       = azurerm_mssql_server_vulnerability_assessment.va_primary[*].id
}

output "secondary_mssql_server_vulnerability_assessment_id" {
  description = "The ID of the Secondary MS SQL Server Vulnerability Assessment."
  value       = azurerm_mssql_server_vulnerability_assessment.va_secondary[*].id
}

output "secondary_mssql_server_security_alert_policy_id" {
  description = "The ID of the Secondary MS SQL Server Security Alert Policy."
  value       = azurerm_mssql_server_security_alert_policy.sap_secondary[*].id
}

output "primary_mssql_database_extended_auditing_policy_id" {
  description = "The ID of the MS SQL Database Extended Auditing Policy."
  value       = try(azurerm_mssql_database_extended_auditing_policy.primary)
}

output "primary_mssql_database_vulnerability_assessment_rule_baseline_id" {
  description = "The ID of the Database Vulnerability Assessment Rule Baseline."
  value       = azurerm_mssql_database_vulnerability_assessment_rule_baseline.db_va_primary[*].id
}

output "mssql_elasticpool_id" {
  description = "The ID of the MS SQL Elastic Pool."
  value       = try(azurerm_mssql_elasticpool.elasticpool[0].id, null)
}

output "mssql_elasticpool_name" {
  description = "The Name of the MS SQL Elastic Pool."
  value       = try(azurerm_mssql_elasticpool.elasticpool[0].name, null)
}

output "primary_mssql_server_firewall_id" {
  description = "The Primary MSSQL Firewall Rule ID."
  value       = { for k, v in azurerm_mssql_firewall_rule.fw01 : k => v.id }
}

output "secondary_mssql_server_firewall_id" {
  description = "The Secondary MSSQL Firewall Rule ID."
  value       = { for k, v in azurerm_mssql_firewall_rule.fw02 : k => v.id }
}

output "mssql_server_job_id" {
  description = "The ID of the Elastic Job."
  value       = azurerm_mssql_job_agent.ja_primary[*].id
}

output "mssql_server_job_agent_id" {
  description = "The ID of the Elastic Job Agent."
  value       = azurerm_mssql_job_agent.ja_primary[*].id
}

output "mssql_server_job_credential_id" {
  description = "The ID of the Elastic Job Credential."
  value       = { for k, v in azurerm_mssql_job_credential.jc_primary : k => v.id }
}

output "mssql_server_job_schedule_id" {
  description = "The ID of the Elastic Job Schedule."
  value       = { for k, v in azurerm_mssql_job_schedule.js_primary : k => v.id }
}

output "mssql_server_job_step_id" {
  description = "The ID of the Elastic Job Step."
  value       = { for k, v in azurerm_mssql_job_step.js_primary : k => v.id }
}

output "mssql_server_job_target_group_id" {
  description = "The ID of the Elastic Job Target Groups."
  value       = { for k, v in azurerm_mssql_job_target_group.jtg_primary : k => v.id }
}

output "mssql_server_outbound_firewall_rule_id" {
  description = "The SQL Outbound Firewall Rule ID."
  value       = { for k, v in azurerm_mssql_outbound_firewall_rule.main : k => v.id }
}

output "mssql_failover_group_id" {
  description = "A failover group of databases on a collection of Azure SQL servers."
  value       = element(concat(azurerm_mssql_failover_group.fog[*].id, [""]), 0)
}

output "mssql_failover_group_partner_server" {
  description = "Map of Azure SQL failover group names to their corresponding partner (secondary) SQL server details."
  value       = { for k, v in azurerm_mssql_failover_group.fog[*] : k => v.partner_server }
}

output "primary_mssql_server_private_endpoint" {
  description = "id of the Primary SQL server Private Endpoint"
  value       = element(concat(azurerm_private_endpoint.pep_primary[*].id, [""]), 0)
}
