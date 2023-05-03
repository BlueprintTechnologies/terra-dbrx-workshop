#### Creates the dev databricks workspace and keyvault
# Then proceeds to create the metastore
# and attach the dev workspace to the metastore

#load script conf
$scriptConfig = get-content "$PSScriptRoot/script.conf" | convertfrom-json   
if(-not (az account show)) {
    az login | out-null
    az account set --subscription $scriptConfig.subscription_name
}

cd "$PSScriptRoot/env_dev/workspace" 
terraform init --backend-config="workspace-dev.backend.conf"
#terraform plan -out workspace.plan
terraform apply


# gather required dynamic variables
$workspace_outputs = terraform output -json | convertfrom-json
$workspace_url = $workspace_outputs.workspace_url.value 
$access_connector_id = $workspace_outputs.access_connector_id.value
$workspace_id = $workspace_outputs.workspace_id.value
$keyvault_id = $workspace_outputs.keyvault_id.value
$keyvault_uri = $workspace_outputs.keyvault_uri.value
$ext_storage_url =  $workspace_outputs.external_storage_url.value

# generate AAD token for databricks authentication
# magic guid is the databricks service resource -- https://learn.microsoft.com/en-us/azure/databricks/dev-tools/api/latest/aad/user-aad-token
# Authenticating with an Azure AD token leverages the fact that SCIM provisioning is enabled for your workspace and Azure tenant
# 
$aad_pat = az account get-access-token --resource 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d --query "accessToken" --output tsv  

# Creating a metastore requires Databricks Account Admin privledges
cd "$PSScriptRoot/metastore"   
terraform init --backend-config="metastore.backend.conf"
#terraform plan -var workspace_url="$workspace_url" -var access_connector_id="$access_connector_id" -var workspace_id="$workspace_id" -var auth_token="$aad_pat" -out metastore.plan
terraform apply -var workspace_url="$workspace_url" -var access_connector_id="$access_connector_id" -var workspace_id="$workspace_id" -var auth_token="$aad_pat"

cd "$PSScriptRoot/env_dev/workspace_administration"
terraform init --backend-config="workspace-admin.backend.conf"

$varFileLocation = "./workspace_admin.tfvars"
$varFileName = (Get-Item $varFileLocation).Name
$fileContents = "
keyvault_uri = `"$keyvault_uri`"
keyvault_id = `"$keyvault_id`"
access_connector_id = `"$access_connector_id`"
workspace_url = `"$workspace_url`"
ext_storage_url = `"$ext_storage_url`"
"
$fileContents | out-file $varFileLocation -Force -Encoding utf8

#terraform plan -var workspace_url="$workspace_url" -var access_connector_id="$access_connector_id" -var workspace_id="$workspace_id" -var auth_token="$aad_pat" -out workspace_admin.plan
terraform apply -var-file="$varFileName" -var auth_token="$aad_pat"