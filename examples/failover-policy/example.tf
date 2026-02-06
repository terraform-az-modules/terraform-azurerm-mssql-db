provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current_client_config" {}

locals {
  name        = "app"
  environment = "qa"
  location    = "centralindia"
  label_order = ["name", "environment", "location"]
}

##----------------------------------------------------------------------------- 
## Resource Group
##-----------------------------------------------------------------------------

module "resource_group" {
  source                   = "terraform-az-modules/resource-group/azurerm"
  version                  = "1.0.3"
  name                     = local.name
  environment              = local.environment
  label_order              = local.label_order
  location                 = local.location
  resource_position_prefix = false
}

##----------------------------------------------------------------------------- 
## Vnet
##-----------------------------------------------------------------------------

module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
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
  version                     = "1.0.2"
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
  version             = "1.0.4"
  name                = local.name
  environment         = local.environment
  resource_group_name = module.resource_group.resource_group_name
  label_order         = local.label_order
  private_dns_config = [
    {
      resource_type = "key_vault"
      vnet_ids      = [module.vnet.vnet_id]
    }
  ]
}


# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------
module "vault" {
  source                        = "terraform-az-modules/key-vault/azurerm"
  version                       = "1.0.4"
  name                          = local.name
  environment                   = local.environment
  label_order                   = local.label_order
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  subnet_id                     = module.subnet.subnet_ids.subnet1
  public_network_access_enabled = true
  private_dns_zone_ids          = module.private_dns_zone.private_dns_zone_ids.key_vault
  soft_delete_retention_days    = 7
  sku_name                      = "premium"
  network_acls = {
    bypass         = "AzureServices"
    default_action = "Allow"
    ip_rules       = ["0.0.0.0/0"]
  }
  reader_objects_ids = {
    "Key Vault Administrator" = {
      role_definition_name = "Key Vault Administrator"
      principal_id         = data.azurerm_client_config.current_client_config.object_id
    }
  }
  enable_rbac_authorization  = true
  diagnostic_setting_enable  = true
  log_analytics_workspace_id = module.log-analytics.workspace_id
}

module "mssql-server" {
  depends_on            = [module.resource_group, module.vnet, module.vault]
  source                = "../.."
  name                  = local.name
  environment           = local.environment
  label_order           = local.label_order
  resource_group_name   = module.resource_group.resource_group_name
  location              = module.resource_group.resource_group_location
  encryption            = true
  sql_server_version    = "12.0"
  administrator_login   = "mssqladmin"
  key_vault_id          = module.vault.id
  enable_mssql_db       = true
  enable_failover_group = true
  read_write_endpoint_failover_policy = {
    mode          = "Automatic"
    grace_minutes = 60
  }
  enable_private_endpoint            = true
  private_endpoint_subnet_id         = module.subnet.subnet_ids.subnet1
  enable_transparent_data_encryption = true
  enable_diagnostic                  = true
  enable_log_monitoring              = true
  log_analytics_workspace_id         = module.log-analytics.workspace_id
}

