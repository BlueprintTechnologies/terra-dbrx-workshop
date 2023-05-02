## General variables
variable "location" {}
variable "environment" {}
variable "app_name" {}
variable "tags" {
    default = {}
}

# workspace storage account vars
variable stg_account_name {}
variable stg_container_name {}
variable stg_account_tier {}
variable stg_account_replication_type {}
variable stg_account_kind {}
variable stg_is_hns_enabled {}

## Databricks variables
variable "databricks_sku" {}

## keyvault variables
variable "kv_sku_name" {}
variable "kv_soft_delete_retention_days" {}
