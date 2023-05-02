locals {
  tags = merge(var.tags,{})
}

#create ADLS gen 2 Storage
module "adls" {
  source  = "../../modules/adls"
  resource_group_name = var.resource_group_name
  tags = local.tags
  adls_name = var.stg_account_name
  container_name = var.stg_container_name
  account_tier = var.stg_account_tier
  account_replication_type = var.stg_account_replication_type
  account_kind = var.stg_account_kind
  is_hns_enabled = var.stg_is_hns_enabled
}

module metastore {
    source = "../../modules/metastore"
    storage_container_name = var.stg_container_name
    storage_account_name =var.stg_container_name
    workspace_url = var.workspace_url
    workspace_id = var.workspace_id
    access_connector_id = var.access_connector_id
    metastore_id = var.metastore_id
    metastore_name = var.metastore_name
    metastore_owner = var.metastore_owner
}