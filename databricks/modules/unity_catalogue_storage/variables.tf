variable "rg_name" {
    description = "The name of the resource group in which to create the Databricks workspace."
    type        = string
}

variable "rg_location" {
    description = "The location of the resource group in which to create the Databricks workspace."
    type        = string
}

variable "unity_catalogue_principal_id" {
    description = "value of the principal id of the unity catalogue"
}
