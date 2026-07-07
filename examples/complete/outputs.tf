##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------

output "primary_mssql_server_id" {
  description = "The primary Microsoft SQL Server ID"
  value       = module.mssql-server.primary_mssql_server_id
}

output "primary_mssql_server_fqdn" {
  description = "The fully qualified domain name of the primary Azure SQL Server"
  value       = module.mssql-server.primary_mssql_server_fqdn
}

output "primary_mssql_server_admin_user" {
  description = "SQL database administrator login id"
  value       = module.mssql-server.primary_mssql_server_admin_user
  sensitive   = true
}

output "primary_mssql_server_admin_password" {
  description = "SQL database administrator login password"
  value       = module.mssql-server.primary_mssql_server_admin_password
  sensitive   = true
}

output "primary_mssql_server_database_ids" {
  description = "Map of SQL Database IDs keyed by database name"
  value       = module.mssql-server.primary_mssql_server_database_ids
}

output "primary_mssql_server_database_names" {
  description = "Map of SQL Database names keyed by database name"
  value       = module.mssql-server.primary_mssql_server_database_names
}

output "mssql_elasticpool_name" {
  description = "The Name of ElasticPool."
  value       = module.mssql-server.mssql_elasticpool_name
}

output "primary_mssql_server_dns_alias_record_set" {
  description = "The fully qualified DNS record for alias."
  value       = module.mssql-server.primary_mssql_server_dns_alias_record_set
}