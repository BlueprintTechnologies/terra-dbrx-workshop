#general info
variable resource_group_name {
    description = "resource group to deploy metastore storage account into"
}
variable metastore_id {
    default = ""
}
variable tags{}
# metastore storage account vars
variable stg_container_name {}
variable stg_account_name {}
variable stg_account_tier {}
variable stg_account_replication_type {}
variable stg_account_kind {}
variable stg_is_hns_enabled {}
variable metastore_name {}
variable metastore_owner {}

variable auth_token {
    sensitive = true
}

# workspace  to attach info
variable workspace_url {}
variable workspace_id  {}
variable access_connector_id {}