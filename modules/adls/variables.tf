variable "resource_group_name" {}

variable "adls_name" {}
variable "account_tier" {}
variable "account_replication_type" {} 
variable "account_kind" {}
variable "is_hns_enabled" {}
variable container_name {
    default = "" # default to not creating a container unless specified
}
variable "tags" {}