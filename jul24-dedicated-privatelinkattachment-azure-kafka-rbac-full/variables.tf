variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)."
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret."
  type        = string
  sensitive   = true
}

variable "azure_subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Azure Resource Group where the virtual network is located."
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the Azure Virtual Network."
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet within the virtual network for the private endpoint."
  type        = string
}

variable "region" {
  description = "The region of the Azure resources."
  type        = string
}

variable "location" {
  description = "The Azure location/region where resources will be created."
  type        = string
}

variable "cku" {
  description = "The number of Confluent Kafka Units (CKU) for the dedicated cluster."
  type        = number
  default     = 2
}
