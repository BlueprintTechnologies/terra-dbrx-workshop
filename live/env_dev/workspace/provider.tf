terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.41.0"
    }
    databricks = {
        source = "databricks/databricks"
        version = "1.9.1"  
    }
  }
	backend "azurerm" {}
}

provider "azurerm"{
   features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    api_management {
      purge_soft_delete_on_destroy = true
    }
   }
}

provider "databricks" {}