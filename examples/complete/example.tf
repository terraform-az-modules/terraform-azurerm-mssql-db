provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current_client_config" {}

locals {
  name        = "app"
  environment = "test"
  location    = "centralindia"
  label_order = ["name", "environment", "location"]
}

##----------------------------------------------------------------------------- 
## Resource Group
##-----------------------------------------------------------------------------

module "resource_group" {
  source                   = "terraform-az-modules/resource-group/azurerm"
  version                  = "1.0.4"
  name                     = local.name
  environment              = local.environment
  label_order              = local.label_order
  location                 = local.location
  resource_position_prefix = true
}

##----------------------------------------------------------------------------- 
## Vnet
##-----------------------------------------------------------------------------

module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.4"
  name                = local.name
  environment         = local.environment
  label_order         = local.label_order
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##----------------------------------------------------------------------------- 
## Subnet 
##-----------------------------------------------------------------------------

module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
  environment          = local.environment
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name

  subnets = [
    {
      name            = "subnet1"
      subnet_prefixes = ["10.0.1.0/24"]
    }
  ]

  # route_table
  enable_route_table = false
}

##----------------------------------------------------------------------------- 
## Log Analytics
##-----------------------------------------------------------------------------

module "log-analytics" {
  source                      = "terraform-az-modules/log-analytics/azurerm"
  version                     = "2.0.0"
  name                        = local.name
  environment                 = local.environment
  label_order                 = local.label_order
  log_analytics_workspace_sku = "PerGB2018"
  resource_group_name         = module.resource_group.resource_group_name
  location                    = module.resource_group.resource_group_location
  log_analytics_workspace_id  = module.log-analytics.workspace_id
}

# ------------------------------------------------------------------------------
# Private DNS Zone
# ------------------------------------------------------------------------------
module "private_dns_zone" {
  source              = "terraform-az-modules/private-dns/azurerm"
  version             = "1.0.7"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  label_order         = local.label_order
  private_dns_config = [
    {
      resource_type = "sql_server"
      vnet_ids      = [module.vnet.vnet_id]
    }
  ]
}

##-----------------------------------------------------------------------------
# Storage Account module call
##-----------------------------------------------------------------------------

module "storage-account" {
  source  = "terraform-az-modules/storage/azurerm"
  version = "1.0.0"

  name                     = local.name
  environment              = local.environment
  label_order              = local.label_order
  location                 = module.resource_group.resource_group_location
  resource_group_name      = module.resource_group.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  ##   Storage Container
  containers_list = [
    { name = "app-test", access_type = "private" },
  ]
}

# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------
module "vault" {
  source                        = "terraform-az-modules/key-vault/azurerm"
  version                       = "3.1.0"
  name                          = "test1231"
  environment                   = local.environment
  label_order                   = local.label_order
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  subnet_id                     = module.subnet.subnet_ids.subnet1
  public_network_access_enabled = true
  sku_name                      = "standard"
  enable_private_endpoint       = false
  # soft_delete_retention_days    = 7
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["0.0.0.0/0"]
  }
  reader_objects_ids = {
    "Key Vault Administrator" = {
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }

  diagnostic_setting_enable = false
  # log_analytics_workspace_id = module.log-analytics.workspace_id
}

##----------------------------------------------------------------------------- 
## Mssql Server database
##-----------------------------------------------------------------------------

module "mssql-server" {
  # depends_on                                 = [module.resource_group, module.vnet, module.vault]
  source                                     = "../.."
  name                                       = local.name
  environment                                = local.environment
  label_order                                = local.label_order
  resource_position_prefix                   = true
  resource_group_name                        = module.resource_group.resource_group_name
  location                                   = module.resource_group.resource_group_location
  sql_server_version                         = "12.0"
  administrator_login                        = "mssqladmin"
  enable_sql_server_extended_auditing_policy = true
  public_network_access_enabled              = true
  storage_account_blob_endpoint              = module.storage-account.storage_account_primary_blob_endpoint
  storage_account_access_key                 = module.storage-account.storage_primary_access_key
  encryption                                 = true # Pass KV ID when encryption is enabled
  key_vault_id                               = module.vault.id
  key_type                                   = "RSA" #RSA-HSM is supported by kv premium sku 
  enable_mssql_db                            = true
  databases = {
    appdb = {
      sku_name                            = "Basic"
      max_size_gb                         = 2
      geo_backup_enabled                  = false
      transparent_data_encryption_enabled = true
    }
    reportingdb = {
      sku_name    = "Basic"
      max_size_gb = 2
    }
  }
  enable_elasticpool = false
  # elasticpool_max_size_gb = 4.8828125 
  sku = {
    name     = "BasicPool"
    tier     = "Basic"
    capacity = 50
  }

  per_database_settings = {
    min_capacity = 0
    max_capacity = 5
  }
  enable_dns_alias           = true
  enable_private_endpoint    = true
  private_endpoint_subnet_id = module.subnet.subnet_ids.subnet1
  private_dns_zone_ids       = [module.private_dns_zone.private_dns_zone_ids.sql_server]
  enable_diagnostic          = true
  enable_log_monitoring      = false
  log_analytics_workspace_id = module.log-analytics.workspace_id
}