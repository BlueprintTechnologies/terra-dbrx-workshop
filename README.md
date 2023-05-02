## Introduction 

This repo is a quick start for setting up a new Databricks workspace, accompanying storage account, keyvault, and managed identity via an access connector.  It also configures a new metastore for your Azure region of choice and provides examples of creating workspace administration resources such as additional user(s), assigning a user to a workspace group, clusters, etc.

## Getting Started
___
### Prerequisites
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
    * This repo uses powershell as an example of orchestrating the different Terraform configuration.  It is by no means required if you'd rather use a different method.


High-level resources created

![alt text](img/resources.png "These are resources")



