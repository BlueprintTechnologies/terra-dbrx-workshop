variable resource_group_name {}
variable tags {}
variable tenant_id {
  description = "Azure AD tenant ID"
}


variable "kv_name" {
    description = "Keyvault Name"
    type = string
}

variable "sku_name" {
    description = "The Name of the SKU used for this Key Vault"
    type = string
    validation {
      condition = contains(["standard","premium"],var.sku_name)
      error_message = "Sku Name must be either 'standard' or 'premium'"
    }
}

variable "soft_delete_retention_days" {
    description = "The number of days that items should be retained for once soft-deleted"
    type = number
    validation {
      condition = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
      error_message = "soft_delete_retention_days must be inclusively between 7 and 90 days"
    }
}