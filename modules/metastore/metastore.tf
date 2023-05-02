
#***********************
# Metastore configuration
#***********************
# You can only have one metastore configured per azure region
# We're using a local variable to retrieve the metastore ID in both scenarios
  

locals {
  metastore_id = (var.metastore_id != "" ? var.metastore_id  : databricks_metastore.metastore[0].id  )
}
terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.9.1"
    }
  }
}

resource "databricks_metastore" "metastore" {
  # https://developer.hashicorp.com/terraform/language/expressions/conditionals
  count = var.metastore_id == "" ? 1: 0
  name = var.metastore_name
  storage_root = format("abfss://${var.storage_container_name}@${var.storage_account_name}.dfs.core.windows.net/")
  owner = var.metastore_owner
  force_destroy = true
}

# assign access connector to metastore to be leveraged by unity catalog
resource "databricks_metastore_data_access" "managedID" {
  metastore_id = local.metastore_id
  name         = "managedid_dataaccess"
  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
  is_default = true
}

# assign metastore to workspace
resource "databricks_metastore_assignment" "metastore_assignment" {
  metastore_id = local.metastore_id
  workspace_id = var.workspace_id
}

