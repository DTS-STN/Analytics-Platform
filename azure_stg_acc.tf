terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
provider "azurerm" {
  features {}
}
resource "azurerm_storage_account" "gktestterrascript" {
  name                     = "gktestterrascript"
  resource_group_name      = "SAEB-DataAnalytics"
  location                 = "canadacentral"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
