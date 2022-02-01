#TODO: declare backend to specify where to keep state file, provide version number

terraform {
  # backend "azurerm" {
  #   resource_group_name  = 
  #   storage_account_name = 
  #   container_name       = 
  #   key                  =
  # }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.89.0"
    }
    databricks = {
      source = "databrickslabs/databricks"
      version = "0.4.4"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "databricks"{} 

