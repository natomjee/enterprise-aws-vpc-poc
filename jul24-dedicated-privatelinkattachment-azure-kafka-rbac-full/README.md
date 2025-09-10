# Confluent Cloud Dual-Cluster Setup: Dedicated + Enterprise with Azure Private Link

This Terraform configuration creates **both** a Dedicated and Enterprise Kafka cluster in the same Confluent Cloud environment, connected via Azure Private Link.

## Overview

This configuration provisions:
- A Confluent Cloud environment
- **Two Kafka clusters**:
  - **Dedicated cluster** (`inventory`) - with configurable CKU
  - **Enterprise cluster** (`enterprise-cluster`) - multi-tenant
- Azure Private Link attachment and connection (shared between clusters)
- Separate service accounts and RBAC for each cluster
- Topics and API keys for both clusters
- Azure private endpoint infrastructure (VNet, subnet, NSG, DNS)

## Cluster Comparison

| Feature | Dedicated Cluster | Enterprise Cluster |
|---------|------------------|-------------------|
| **Configuration** | `dedicated { cku = 2 }` | `enterprise {}` |
| **Resources** | Dedicated compute/storage | Multi-tenant shared |
| **Scaling** | CKU-based scaling | Automatic scaling |
| **Pricing** | Fixed CKU cost | Usage-based |
| **Service Accounts** | `app-manager`, `app-producer`, `app-consumer` | `enterprise-app-manager`, `enterprise-app-producer`, `enterprise-app-consumer` |
| **Topics** | `jee-orders` | `enterprise-orders` |

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

**Shared Resources:**
- Environment (`confluent_environment.staging`)
- Private Link Attachment (`confluent_private_link_attachment.pla`)
- Private Link Attachment Connection (`confluent_private_link_attachment_connection.plac`)

**Dedicated Cluster Resources:**
- Kafka Cluster (`confluent_kafka_cluster.dedicated`)
- Service Accounts: `app-manager`, `app-producer`, `app-consumer`
- Topic: `jee-orders`
- API Keys and Role Bindings for dedicated cluster

**Enterprise Cluster Resources:**
- Kafka Cluster (`confluent_kafka_cluster.enterprise`)
- Service Accounts: `enterprise-app-manager`, `enterprise-app-producer`, `enterprise-app-consumer`
- Topic: `enterprise-orders`
- API Keys and Role Bindings for enterprise cluster

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

**Dedicated Cluster Service Accounts:**
1. **app-manager**: CloudClusterAdmin role for dedicated cluster management
2. **app-producer**: DeveloperWrite role for `jee-orders` topic
3. **app-consumer**: DeveloperRead role for `jee-orders` topic

**Enterprise Cluster Service Accounts:**
1. **enterprise-app-manager**: CloudClusterAdmin role for enterprise cluster management  
2. **enterprise-app-producer**: DeveloperWrite role for `enterprise-orders` topic
3. **enterprise-app-consumer**: DeveloperRead role for `enterprise-orders` topic

## Outputs

After successful deployment, you'll get:
- Environment ID (shared)
- Both Cluster IDs and names
- All Service Account details (6 total)
- All API Keys (6 total, marked as sensitive)
- Azure Private Endpoint information
- Private IP addresses and DNS configuration

## Use Cases

This dual-cluster setup is ideal for:
- **Multi-environment workloads**: Production (dedicated) + Development (enterprise)
- **Different SLA requirements**: Critical apps on dedicated, others on enterprise  
- **Cost optimization**: High-throughput on dedicated, low-volume on enterprise
- **Migration scenarios**: Gradual migration between cluster types
- **Compliance separation**: Different data classifications per cluster

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
