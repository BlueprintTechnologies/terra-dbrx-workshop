locals {}

data "databricks_spark_version" "latest" {}
data "databricks_node_type" "smallest" {
  local_disk = true
}
data "databricks_group" "workspace_admin_group" {
    display_name = "admins"
}

resource "databricks_secret_scope" "kvss" {
  name = "keyvault-managed"

  keyvault_metadata {
    resource_id = var.keyvault_id
    dns_name    = var.keyvault_uri
  }
}

### fill in example
/*
resource "databricks_notebook" "notebook_example" {
  path     = "${data.databricks_current_user.me.home}/Terraform"
  language = "PYTHON"
}
*/

resource "databricks_cluster" "hold_me_closer_tiny_cluster" {
    cluster_name = "cluster example"
    spark_version             = data.databricks_spark_version.latest.id
    node_type_id              = data.databricks_node_type.smallest.id
    autotermination_minutes   = 10
    data_security_mode        = "USER_ISOLATION"
    autoscale {
        min_workers = 1
        max_workers = 5
    }
}

resource databricks_user "co_presenter" {
    user_name = var.additional_user.user_name
    display_name = var.additional_user.display_name
}

resource "databricks_group_member" "admin_assignment" {
  group_id = data.databricks_group.workspace_admin_group.id
  member_id = databricks_user.co_presenter.id
}

resource "databricks_storage_credential" "external_mi" {
  name = "managedid_credentials"
  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
  comment = "Managed identity credential managed by Terraform"
}

resource "databricks_external_location" "ext_stg" {
  name = "external"
  url = var.ext_storage_url
  credential_name = databricks_storage_credential.external_mi.id
  comment         = "Managed by terraform"
}