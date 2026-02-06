<!-- BEGIN_TF_DOCS -->

# Terraform Azure MSSQL DB

This directory contains an example usage of the **terraform-azure-mssql-db**. It demonstrates how to use the module with default settings or with custom configurations.

---

## 📋 Requirements

| Name      | Version   |
|-----------|-----------|
| Terraform | >= 1.6.6  |
| Azurerm   | >= 3.116.0|

---

## 🔌 Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.53.0 |


## 📦 Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mssql-server"></a> [mssql-server](#module\_mssql-server) | ../../ | n/a |
| <a name="module_log-analytics"></a> [log-analytics](#module\_log-analytics) | terraform-az-modules/log-analytics/azurerm | 1.0.2 |
| <a name="module_private_dns"></a> [private\_dns](#module\_private\_dns) | terraform-az-modules/private-dns/azurerm | 1.0.4 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-az-modules/resource-group/azurerm | 1.0.3 |
| <a name="module_subnet"></a> [subnet](#module\_subnet) | terraform-az-modules/subnet/azurerm | 1.0.1 |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | terraform-az-modules/vnet/azurerm | 1.0.3 |
| <a name="module_vault"></a> [vault](#module\_vault) | terraform-az-modules/key-vault/azurerm | 1.0.4 |


---

## 🏗️ Resources

No resources are directly created in this example.

---

## 🔧 Inputs

No input variables are defined in this example.

---

## 📤 Outputs

| Name | Description |
|------|-------------|
| <a name="output_primary_mssql_server_id"></a> [primary\_mssql_server\_id](#output\_primary\_mssql_server\_id) | The ID of the Primary MSSQL Server. |
| <a name="output_primary_mssql_server_fqdn"></a> [primary\_mssql_server\_fqdn](#output\primary\_mssql_server\_fqdn) | The Fullt Qualified Domain Name of the Primary MSSQL Server. |
| <a name="output_primary_mssql_server_admin_user"></a> [primary\_mssql_server_admin\_user](#output\primary\_mssql_server_admin\_user) | The Administrator Name of Primary SQL Server. |
| <a name="output_primary_mssql_server_admin_passwords"></a> [primary\_mssql_server_admin\_password](#output\primary\_mssql_server\_admin\_password) | The Password of administrator of Primary SQL Server. |
| <a name="output_primary_mssql_database_id"></a> [primary\_mssql_database\_id](#output\_primary\_mssql_database\_id) | The ID of MSSQL Database. |
| <a name="output_primary_mssql_database_name"></a> [primary\_mssql_database\_name](#output\_primary\_mssql_database\_name) | The Name of MSSQL Database. |
| <a name="output_mssql_failover_group_id"></a> [mssql\_failover_group\_id](#output\_mssql\_failover_group\_id) | The ID of the MSSQL Failover Group. |
<!-- END_TF_DOCS -->