provider "azurerm" {
  features {}
}

module "mssql-db" {
  source = "../../"
}
