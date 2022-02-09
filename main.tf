# Declare some local variables
locals {
  build_environment = var.environment == "production" ? "Prod" : "Dev"
  common_tags = {
    ProductPortfolio = "SAEB"
    Product      = "SAEB Analytics Platform"
    ProductOwner = "Shaun Laughland"
    CreatedBy    = "Terraform"
  }
}

# Refer to existing Azure resource group
data "azurerm_resource_group" "saeb" {
  name     = "SAEB-AnalyticsPlatform-Sndbx"
}

resource "random_string" "random" {
  length = 4
  upper = false
  special = false
  number = false
}


# Create storage account for main input and curated CSV files as well as for synapse filesystem
resource "azurerm_storage_account" "saeb_storage" {
  name                     = "stapsndbxca01${random_string.random.result}"
  resource_group_name      = "${data.azurerm_resource_group.saeb.name}"
  location                 = "${data.azurerm_resource_group.saeb.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.common_tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "saeb_data_lake_fs" {
  name               = "fssynapseworkspace"
  storage_account_id = azurerm_storage_account.saeb_storage.id
}


# Creates all the containers at once
resource "azurerm_storage_container" "saeb_storage_container" {
  for_each              = toset(var.storage_containers)
  name                  = each.key
  storage_account_name  = azurerm_storage_account.saeb_storage.name
  container_access_type = "private"
}

# Create ADF
resource "azurerm_data_factory" "saeb_adf" {
  name                = "adf-saeb-dev-01-${random_string.random.result}"
  location            = "${data.azurerm_resource_group.saeb.location}"
  resource_group_name = "${data.azurerm_resource_group.saeb.name}"
}


# Create Databricks workspace and associate with a repo
resource "azurerm_databricks_workspace" "saeb_databricks_workspace" {
  name                = "dbw-saeb-dev-01-${random_string.random.result}"
  resource_group_name = "${data.azurerm_resource_group.saeb.name}"
  location            = "${data.azurerm_resource_group.saeb.location}"
  sku                 = "standard"

  tags = local.common_tags
}

#resource "databricks_repo" "saeb_databricks_repo" {
#  url = "https://github.com/DTS-STN/AP-Databricks.git"
#}


# Create logic app + storage account + app service plan that all work together
resource "azurerm_storage_account" "saeb_logic_app_storage" {
  name                     = "salogicappdevca02${random_string.random.result}"
  resource_group_name      = "${data.azurerm_resource_group.saeb.name}"
  location                 = "${data.azurerm_resource_group.saeb.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "saeb_service_plan" {
  name                = "asp-saeb-dev-02-${random_string.random.result}"
  location            = "${data.azurerm_resource_group.saeb.location}"
  resource_group_name = "${data.azurerm_resource_group.saeb.name}"

  sku {
    tier = "WorkflowStandard"
    size = "WS1"
  }
}

resource "azurerm_logic_app_standard" "saeb_logic_app" {
  name                       = "logic-saeb-dev-01-${random_string.random.result}"
  location                   = "${data.azurerm_resource_group.saeb.location}"
  resource_group_name        = "${data.azurerm_resource_group.saeb.name}"
  app_service_plan_id        = azurerm_app_service_plan.saeb_service_plan.id
  storage_account_name       = azurerm_storage_account.saeb_logic_app_storage.name
  storage_account_access_key = azurerm_storage_account.saeb_logic_app_storage.primary_access_key
}

# Create Synapse workspace with dedicated SQL Pool
resource "azurerm_synapse_workspace" "saeb_synapse" {
  name                                 = "synw-saeb-dev-01-${random_string.random.result}"
  resource_group_name                  = "${data.azurerm_resource_group.saeb.name}"
  location                             = "${data.azurerm_resource_group.saeb.location}"
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.saeb_data_lake_fs.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
}

resource "azurerm_synapse_sql_pool" "saeb_synapse_sqlpool" {
  name                 = "syn_sqlpool_saeb_dev_01"
  synapse_workspace_id = azurerm_synapse_workspace.saeb_synapse.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}

# Key vault

# Reference to client configuration in order to access tenant ID and subscription ID
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "saeb_keyvault" {
  name                        = "kv-saeb-dev-01"
  location                    = "${data.azurerm_resource_group.saeb.location}"
  resource_group_name         = azurerm_resource_group.saeb.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id # replace this with service principal

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
      "purge",
      "recover"
    ]

    storage_permissions = [
      "get",
    ]
  }
}

resource "azurerm_key_vault_secret" "saeb_test_secret" {
  name         = "secret-sauce"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.saeb_keyvault.id
}