data "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
}

locals {
  create_storage_container = var.container_name != ""? true:false
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.adls_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  is_hns_enabled           = var.is_hns_enabled
  tags = var.tags
}

resource "azurerm_storage_data_lake_gen2_filesystem" "container" {
  count = local.create_storage_container? 1:0
  name               = var.container_name
  storage_account_id = azurerm_storage_account.storage_account.id
}

output "storage_account_name" {
  description = "adls storage account name"
  value = "${azurerm_storage_account.storage_account.name}"
}

output "storage_container_name" {
  description = "adls storage container name"
  value = local.create_storage_container ? "${azurerm_storage_data_lake_gen2_filesystem.container[0].name}":null
}

output "storage_acct_id" {
  value = azurerm_storage_account.storage_account.id
}
