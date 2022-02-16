# Declare some local variables
locals {
  build_environment = lookup({sandbox="Sndbx", development="Dev", production="Prod"}, var.environment, "none")
  common_tags = {
    ProductPortfolio = "SAEB"
    Product      = "SAEB Analytics Platform"
    ProductOwner = "Shaun Laughland"
    CreatedBy    = "Terraform"
  }
}

# Refer to existing Azure resource group
data "azurerm_resource_group" "saeb" {
  name     = "SAEB-AnalyticsPlatform-${local.build_environment}"
}

# Create storage account for main input and curated CSV files as well as for synapse filesystem
resource "azurerm_storage_account" "saeb_storage" {
  name                     = lower("stsaebbi${local.build_environment}ca01")
  resource_group_name      = "${data.azurerm_resource_group.saeb.name}"
  location                 = "${data.azurerm_resource_group.saeb.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.common_tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "saeb_data_lake_fs" {
  name               = lower("fs-saeb-synapseworkspace-${local.build_environment}-ca-01")
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
  name                = lower("adf-saeb-ap-${local.build_environment}-ca-01")
  location            = "${data.azurerm_resource_group.saeb.location}"
  resource_group_name = "${data.azurerm_resource_group.saeb.name}"
}


# Create Databricks workspace and associate with a repo
resource "azurerm_databricks_workspace" "saeb_databricks_workspace" {
  name                = lower("dbw-saeb-ap-${local.build_environment}-ca-01")
  resource_group_name = "${data.azurerm_resource_group.saeb.name}"
  location            = "${data.azurerm_resource_group.saeb.location}"
  sku                 = "standard"

  tags = local.common_tags
}

resource "databricks_repo" "saeb_databricks_repo" {
  count = local.build_environment == "Dev" ? 1 : 0
  url = "https://github.com/DTS-STN/AP-Databricks.git"
}


# Create logic app + storage account + app service plan that all work together
resource "azurerm_storage_account" "saeb_logic_app_storage" {
  name                     = lower("stsaeblogic${local.build_environment}ca01")
  resource_group_name      = "${data.azurerm_resource_group.saeb.name}"
  location                 = "${data.azurerm_resource_group.saeb.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "saeb_service_plan" {
  name                = lower("asp-saeb-ap-${local.build_environment}-ca-01")
  location            = "${data.azurerm_resource_group.saeb.location}"
  resource_group_name = "${data.azurerm_resource_group.saeb.name}"

  sku {
    tier = "WorkflowStandard"
    size = "WS1"
  }
}

resource "azurerm_logic_app_standard" "saeb_logic_app" {
  name                       = lower("logic-saeb-ap-${local.build_environment}-ca-01")
  location                   = "${data.azurerm_resource_group.saeb.location}"
  resource_group_name        = "${data.azurerm_resource_group.saeb.name}"
  app_service_plan_id        = azurerm_app_service_plan.saeb_service_plan.id
  storage_account_name       = azurerm_storage_account.saeb_logic_app_storage.name
  storage_account_access_key = azurerm_storage_account.saeb_logic_app_storage.primary_access_key
}

# Create Synapse workspace with dedicated SQL Pool
resource "azurerm_synapse_workspace" "saeb_synapse" {
  name                                 = lower("synw-saeb-ap-${local.build_environment}-ca-01")
  resource_group_name                  = "${data.azurerm_resource_group.saeb.name}"
  location                             = "${data.azurerm_resource_group.saeb.location}"
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.saeb_data_lake_fs.id
  sql_administrator_login              = "sqladminuser"
  sql_administrator_login_password     = "H@Sh1CoR3!"
}

resource "azurerm_synapse_sql_pool" "saeb_synapse_sqlpool" {
  name                 = lower("syndp_saeb_ap_${local.build_environment}_ca_01")
  synapse_workspace_id = azurerm_synapse_workspace.saeb_synapse.id
  sku_name             = "DW100c"
  create_mode          = "Default"
}
