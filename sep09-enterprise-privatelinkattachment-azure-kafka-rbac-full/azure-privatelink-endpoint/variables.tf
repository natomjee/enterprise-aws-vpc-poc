variable "resource_group_name" {
  description = "The name of the Azure Resource Group where the virtual network is located"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the Azure Virtual Network"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet within the virtual network for the private endpoint"
  type        = string
}

variable "privatelink_service_name" {
  description = "The Private Link Service alias from Confluent Cloud (provided by Confluent)"
  type        = string
}

variable "bootstrap" {
  description = "The bootstrap server (ie: lkc-abcde-vwxyz.eastus.azure.confluent.cloud:9092)"
  type        = string
}

variable "dns_domain_name" {
  description = "The DNS domain name"
  type        = string
}

variable "location" {
  description = "The Azure location/region where resources will be created"
  type        = string
}
