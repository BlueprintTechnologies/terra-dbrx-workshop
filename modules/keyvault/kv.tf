data "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
}

resource "azurerm_key_vault" "kv" {
  name                        = "${var.kv_name}"
  location                    = data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = false
  sku_name                    = var.sku_name
  tags = var.tags
}

output keyvault_id {
  value = azurerm_key_vault.kv.id
}

output keyvault_uri {
  value = azurerm_key_vault.kv.vault_uri
}