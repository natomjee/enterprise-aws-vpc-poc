# Confluent Cloud Dedicated Kafka Cluster with Azure Private Link

This Terraform configuration creates a Confluent Cloud Dedicated Kafka cluster in Azure with Private Link attachment for secure, private connectivity.

## Overview

This configuration provisions:
- A Confluent Cloud environment
- A **Dedicated** Kafka cluster (with configurable CKU)
- Azure Private Link attachment and connection
- Service accounts with RBAC roles
- Kafka topic and API keys
- Azure private endpoint infrastructure (VNet, subnet, NSG, DNS)

## Key Differences from Enterprise Cluster

- Uses `dedicated {}` block instead of `enterprise {}`
- Requires CKU (Confluent Kafka Units) configuration
- Dedicated clusters provide dedicated compute and storage resources
- Different pricing model and performance characteristics

## Prerequisites

1. **Confluent Cloud Account**: API key and secret
2. **Azure Subscription**: With appropriate permissions
3. **Existing Azure Infrastructure**:
   - Resource Group
   - Virtual Network (VNet)
   - Subnet (with private endpoint policies disabled)

## Configuration

### 1. Update terraform.tfvars

```hcl
# Confluent Cloud credentials
confluent_cloud_api_key = "your-api-key"
confluent_cloud_api_secret = "your-api-secret"

# Azure configuration
azure_subscription_id = "your-subscription-id"
resource_group_name = "your-resource-group"
virtual_network_name = "your-vnet-name"
subnet_name = "your-subnet-name"
region = "eastus"
location = "East US"

# Dedicated cluster configuration
cku = 2  # Minimum 2 CKU, can be scaled up
```

### 2. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

## Resources Created

### Confluent Cloud Resources
- Environment (`confluent_environment.staging`)
- Dedicated Kafka Cluster (`confluent_kafka_cluster.dedicated`)
- Private Link Attachment (`confluent_private_link_attachment.pla`)
- Private Link Attachment Connection (`confluent_private_link_attachment_connection.plac`)
- Service Accounts (app-manager, app-producer, app-consumer)
- API Keys and Role Bindings
- Kafka Topic (`jee-orders`)

### Azure Resources
- Private Endpoint
- Network Security Group with Kafka/HTTPS rules
- Private DNS Zone and DNS records
- VNet link for DNS resolution

## CKU Scaling

Dedicated clusters use Confluent Kafka Units (CKU) for capacity:
- **Minimum**: 2 CKU
- **Scaling**: Can be increased based on throughput requirements
- **Performance**: Each CKU provides dedicated compute and storage

## Networking

The private endpoint ensures:
- Traffic stays within Azure backbone
- No internet exposure of Kafka cluster
- DNS resolution through private DNS zones
- Security group rules for required ports (80, 443, 9092)

## Service Accounts and RBAC

Three service accounts are created:
1. **app-manager**: CloudClusterAdmin role for cluster management
2. **app-producer**: DeveloperWrite role for topic production
3. **app-consumer**: DeveloperRead role for topic consumption

## Outputs

After successful deployment, you'll get:
- Environment and Cluster IDs
- Service Account details
- API Keys (marked as sensitive)
- Azure Private Endpoint information
- Private IP addresses and DNS configuration

## Limitations

- Cross-region Private Link connections not supported
- Dedicated clusters have minimum billing commitments
- CKU scaling may have cooldown periods

## Security Notes

- API secrets are marked as sensitive
- Private connectivity ensures data doesn't traverse public internet
- RBAC provides fine-grained access control
- Network security groups restrict traffic to necessary ports

## Cost Considerations

Dedicated clusters have different pricing:
- Fixed cost per CKU hour
- No per-GB ingress/egress charges within Azure region
- Consider CKU requirements based on expected throughput

For more information, see:
- [Confluent Cloud Dedicated Clusters](https://docs.confluent.io/cloud/current/clusters/cluster-types.html#dedicated-clusters)
- [Azure Private Link for Confluent Cloud](https://docs.confluent.io/cloud/current/networking/azure-privatelink.html)
