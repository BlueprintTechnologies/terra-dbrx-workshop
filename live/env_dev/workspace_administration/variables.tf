variable "keyvault_id" {
  description = "Id of Keyvault to manage workspace keyvault backed secret scope"
}
variable keyvault_uri {
    description = "URI of Keyvault to manage workspace keyvault backed secret scope"
}

variable "workspace_url" {}

variable auth_token {
    type = string
    sensitive = true
} 

variable additional_user {
    type = map # or object
}

variable access_connector_id {}

variable ext_storage_url {}