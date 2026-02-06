##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "primary_sql_server_id" {
  description = "The primary Microsoft SQL Server ID"
  value       = module.mssql-server.primary_mssql_server_id
}

output "primary_sql_server_fqdn" {
  description = "The fully qualified domain name of the primary Azure SQL Server"
  value       = module.mssql-server.primary_mssql_server_fqdn
}

output "sql_server_admin_user" {
  description = "SQL database administrator login id"
  value       = module.mssql-server.primary_mssql_server_admin_user
  sensitive   = true
}

output "sql_server_admin_password" {
  description = "SQL database administrator login password"
  value       = module.mssql-server.primary_mssql_server_admin_password
  sensitive   = true
}

output "sql_database_id" {
  description = "The SQL Database ID"
  value       = module.mssql-server.primary_mssql_server_database_id
}

output "sql_database_name" {
  description = "The SQL Database Name"
  value       = module.mssql-server.primary_mssql_server_database_name
}

output "mssql_failover_group_id" {
  description = "The ID of the Managed Instance Failover Group."
  value       = module.mssql-server.mssql_failover_group_id
}