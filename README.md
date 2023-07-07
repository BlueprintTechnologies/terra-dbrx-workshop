# Introduction

This repo is a quick start for setting up a new Databricks workspace, accompanying storage account, keyvault, and managed identity via an access connector.  It also configures a new metastore for your Azure region of choice and provides examples of creating workspace administration resources such as additional user(s), assigning a user to a workspace group, clusters, etc.

# Getting Started
___
## Prerequisites
1. Tools\CLI
    * Terraform ( [Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) )
    * Az CLI ( [install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) )
2. Azure RM Permissions
    * Suscription Contributor to create resource group.
    * Resource Group Contributor for creating resources
3. Databricks
    * Account Administrator - for creating Metastore and associating workspace to the newly created metastore
    * This repo also leverages the fact that SCIM provisioning is setup for Azure AD and Databricks by using an AAD token to authenticate to the created workspace.  An alternative could be to create a Databricks PAT via the workspace UI and passing that in
4. Powershell
    * This repo uses powershell as an example of orchestrating the different Terraform configuration.  It is by no means required if you'd rather use a different method. YMMV


High-level resources created

![alt text](img/resources.png "These are resources")


## Filling out .conf and .tfvars files

We provide examples of configuration and variable files terraform requires to create Databricks resources.  Create a copy of each file in the same location, and remove "example" from the file name.

### live\script.conf.example
subscription_name -- The subscription name where you want to install your databricks resources.

### live\env_dev\workspace\terraform.tfvars
This file defines your databricks workspace, primary storage account, and key vault resources.
 - **app_name** -- used to name the workspace and key vault
   - Your workspace will be named: "<app_name>-<environment>-workspace."
   - Your key vault will be named: "<app_name>-<environment>-kv."
 - **location** -- which Azure region you want your resources created in.  Use the lowercase form, for example: "eastus."
 - **tags** -- This collection of key-value pairs will be added to your resources.
 - **stg_account_name** -- what you want to call your primary storage account
 - **stg_container_name** -- what you want to call your primary storage container, to be created in stg_account_name
 - **stg_account_tier** -- "Standard" or "Premium."
 - **stg_account_replication_type** -- What replication strategy do you want the storage account to use usually "LRS" (locally redundant) or "GRS" (geo-redundant
 - **stg_account_kind** -- what version storage to use. "StorageV2"
 - **stg_is_hns_enabled** -- use hierarchical namespace.  "true"
 - **databricks_sku** -- what "Edition" of Databricks do you want to create?  "standard," "premium," or "trial"
 - **kv_sku_name** -- what version of key vault do you want to create?  "standard"
 - **kv_soft_delete_retention_days** -- how long do you want to keep key vault values in the recycle bin before hard deleting them?, Default is seven days(7).

### live\env_dev\workspace\workspace-dev.backend.conf.example
This file sets up a storage account to store your workspace terraform state file.  The storage account and container should already exist before running the Powershell script at the end.
 - **resource_group_name** -- what do you want to name this resource group?
 - **storage_account_name** -- what do you want to call this storage account?
 - **container_name** -- what do you want to call this container?
 - **key** -- leave this as it is, "workspace_dev.tfstate."

### live\env_dev\workspace_administration\terraform.tfvars
You can define one additional user at creation.
 - **user_name** -- This should be a different email address from your own.
 - **display_name** -- first and last name.

### live\env_dev\workspace_administration\workspace-admin.backend.conf.example
Another terraform state file will be stored in the location set in this file.  The storage account and container should already exist before running the Powershell script at the end.
 - **resource_group_name**  -- what do you want to name this resource group?
 - **storage_account_name** -- what do you want to call this storage account?
 - **container_name** -- what do you want to call this container?
 - **key** -- leave this as it is, "workspace_dev.tfstate."

Once you've created your versions of the conf and tfvars files listed above, you're ready to run "live\provision-dev.ps1."

## SCIM Provisioning
https://docs.databricks.com/administration-guide/users-groups/scim/aad.html

Best practices: https://learn.microsoft.com/en-us/azure/databricks/administration-guide/users-groups/best-practices
