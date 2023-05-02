variable storage_container_name {}
variable storage_account_name {}
variable workspace_url {}
variable workspace_id {}
variable access_connector_id {}
variable metastore_id {
    description = "ID of metastore to attach workspace to.  If no metastore has been created yet, leave default and a metastore will be created"
    default = ""
    type = string
}
variable metastore_name {}
variable metastore_owner {
    description = "User or Group to assign ownership over the created metastore"
}