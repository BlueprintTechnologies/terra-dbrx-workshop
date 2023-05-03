#create resource group
locals {
    tags = merge(var.tags,{
      Lifecycle = "${var.environment}"
  })
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "${var.app_name}-${var.environment}-rg"
  location = var.location
}

#create Databricks workspace
module "databricks" {
  source  = "../../../modules/databricks"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags

  databricks_name = "${var.app_name}-${var.environment}-workspace"
  databricks_sku = var.databricks_sku
  depends_on = [
    azurerm_resource_group.rg
  ]
}

#create Key Vault
module "workspace_keyvault" {
  source  = "../../../modules/keyvault"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
  tenant_id = data.azurerm_client_config.current.tenant_id
  kv_name = "${var.app_name}-${var.environment}-kv"
  sku_name = var.kv_sku_name
  soft_delete_retention_days = var.kv_soft_delete_retention_days
  depends_on = [
    azurerm_resource_group.rg
  ]
}

module "workspace_storage" {
  source  = "../../../modules/adls"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
  adls_name = var.stg_account_name
  container_name = var.stg_container_name
  account_tier = var.stg_account_tier
  account_replication_type = var.stg_account_replication_type
  account_kind = var.stg_account_kind
  is_hns_enabled = var.stg_is_hns_enabled
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource azurerm_key_vault_access_policy "sp_kv_permissions" {
    key_vault_id = module.workspace_keyvault.keyvault_id
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = module.databricks.access_connector_principal_id

    key_permissions = [
      "Get", "List", "Create"
    ]

    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]

    storage_permissions = [
      "Get",
    ]
}

# AzureRM role assignment "Blob storage contributor" to app service principal
resource azurerm_role_assignment "stg_contrib" {
  scope = module.workspace_storage.storage_acct_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.databricks.access_connector_principal_id
}

#***********************
# Outputs
#***********************

output "workspace_url" {
  value = "${module.databricks.workspace_url}"
}

output "workspace_id" {
  value = "${module.databricks.workspace_id}"
}

output "access_connector_id" {
  value = "${module.databricks.access_connector_id}"
}

output "keyvault_id" {
  value = "${module.workspace_keyvault.keyvault_id}"
}

output "keyvault_uri" {
  value = "${module.workspace_keyvault.keyvault_uri}"
}

output "external_storage_url" {
  value = "abfss://${var.stg_container_name}@${var.stg_account_name}.dfs.core.windows.net"
}