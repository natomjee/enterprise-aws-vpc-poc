# Confluent Cloud Enterprise Kafka Cluster with RBAC (No Private Link)

This Terraform configuration creates a Confluent Cloud Enterprise Kafka cluster on Azure with RBAC (Role-Based Access Control) but **without** private link attachments for public internet connectivity.

## Resources Created

- Confluent Environment
- Enterprise Kafka Cluster on Azure
- Service Accounts with unique "sep09-" prefix:
  - `sep09-app-manager` - Cluster admin
  - `sep09-app-producer` - Producer service account
  - `sep09-app-consumer` - Consumer service account
- API Keys for each service account
- Kafka Topic (`jee-orders`)
- RBAC Role Bindings

### Notes

1. See [Sample Project for Confluent Terraform Provider](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/guides/sample-project) that provides step-by-step instructions of running this example.

2. This configuration creates a **public** Kafka cluster accessible over the internet. No private networking is configured.

3. **Confluent Cloud API Keys**: You'll need to set environment variables for Confluent Cloud:
   ```bash
   export TF_VAR_confluent_cloud_api_key="your-api-key"
   export TF_VAR_confluent_cloud_api_secret="your-api-secret"
   ```

## Usage

1. **Clone and Navigate**:
   ```bash
   cd sep09-enterprise-privatelinkattachment-azure-kafka-rbac-full
   ```

2. **Set Environment Variables**:
   ```bash
   export TF_VAR_confluent_cloud_api_key="your-confluent-api-key"
   export TF_VAR_confluent_cloud_api_secret="your-confluent-api-secret"
   ```

3. **Initialize and Apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Variables

- `confluent_cloud_api_key` - Your Confluent Cloud API Key
- `confluent_cloud_api_secret` - Your Confluent Cloud API Secret
- `region` - Azure region (default: "eastus")

## Unique Service Account Names

This configuration uses unique service account names with "sep09-" prefix to avoid conflicts with other deployments:

- `sep09-app-manager`
- `sep09-app-producer` 
- `sep09-app-consumer`
