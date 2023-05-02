terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.9.1"
    }
  }
}

data "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
}

resource "azurerm_databricks_workspace" "dbricks_workspace" {
  name                = "${var.databricks_name}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = var.databricks_sku
  tags = var.tags
}

resource "azurerm_databricks_access_connector" "dbricks_ac" {
  name                = "dbrxconnector"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  identity {
    type = "SystemAssigned"
  }
}

output "workspace_url" {
  description = "databricks workspace url"
  value = "${azurerm_databricks_workspace.dbricks_workspace.workspace_url}"
}

output "access_connector_id" {
  description = "databricks access connector id"
  value = "${azurerm_databricks_access_connector.dbricks_ac.id}"
}

output "workspace_id" {
  description = "databricks workspace id"
  value = "${azurerm_databricks_workspace.dbricks_workspace.workspace_id}"
}

# return the system assigned principal ID for the access conncetor
output "access_connector_principal_id" {
  description = "databricks workspace id"
  value = "${azurerm_databricks_access_connector.dbricks_ac.identity[0].principal_id}"
}