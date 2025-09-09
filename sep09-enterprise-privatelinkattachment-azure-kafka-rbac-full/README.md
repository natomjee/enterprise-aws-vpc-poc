### Notes

1. See [Sample Project for Confluent Terraform Provider](https://registry.terraform.io/providers/confluentinc/confluent/latest/docs/guides/sample-project) that provides step-by-step instructions of running this example.

2. This example assumes that Terraform is run from a host in the private network, where it will have connectivity to the [Kafka REST API](https://docs.confluent.io/cloud/current/api.html#tag/Topic-(v3)) in other words, to the [REST endpoint](https://docs.confluent.io/cloud/current/clusters/broker-config.html#access-cluster-settings-in-the-ccloud-console) on the provisioned Kafka cluster. If it is not, you must make these changes:

    * Update the `confluent_api_key` resources by setting their `disable_wait_for_ready` flag to `true`. Otherwise, Terraform will attempt to validate API key creation by listing topics, which will fail without access to the Kafka REST API. Otherwise, you might see errors like:

        ```
        Error: error waiting for Kafka API Key "[REDACTED]" to sync: error listing Kafka Topics using Kafka API Key "[REDACTED]": Get "[https://[REDACTED]/kafka/v3/clusters/[REDACTED]/topics](https://[REDACTED]/kafka/v3/clusters/[REDACTED]/topics)": GET [https://[REDACTED]/kafka/v3/clusters/[REDACTED]/topics](https://[REDACTED]/kafka/v3/clusters/[REDACTED]/topics) giving up after 5 attempt(s): Get "[https://[REDACTED]/kafka/v3/clusters/[REDACTED]/topics](https://[REDACTED]/kafka/v3/clusters/[REDACTED/topics)": dial tcp [REDACTED]:443: i/o timeout
        ```

    * Remove the `confluent_kafka_topic` resource. These resources are provisioned using the Kafka REST API, which is only accessible from the private network.

3. One common deployment workflow for environments with private networking is as follows:

    * A initial (centrally-run) Terraform deployment provisions infrastructure: network, Kafka cluster, and other resources on cloud provider of your choice to setup private network connectivity (like DNS records)

    * A secondary Terraform deployment (run from within the private network) provisions data-plane resources (Kafka Topics and ACLs)

    * Note that RBAC role bindings can be provisioned in either the first or second step, as they are provisioned through the [Confluent Cloud API](https://docs.confluent.io/cloud/current/api.html), not the [Kafka REST API](https://docs.confluent.io/cloud/current/api.html#tag/Topic-(v3))

### Azure-Specific Requirements

1. **Azure Subscription**: Ensure you have the necessary permissions in your Azure subscription to create:
   - Private Endpoints
   - Private DNS Zones
   - Network Security Groups
   - Resource Groups (if creating new ones)

2. **Virtual Network Setup**: Your Azure Virtual Network should be configured with:
   - Proper address space allocation
   - Subnet dedicated for private endpoints
   - Private endpoint network policies disabled on the subnet

3. **Authentication**: Configure Azure authentication for Terraform using one of these methods:
   - Azure CLI: `az login`
   - Service Principal with environment variables
   - Managed Identity (if running on Azure)

4. **Required Azure CLI Commands**: Before running Terraform, you may need to:
   ```bash
   # Login to Azure
   az login
   
   # Set your subscription (if you have multiple)
   az account set --subscription "your-subscription-id"
   
   # Verify your current subscription
   az account show
   ```

5. **Confluent Cloud API Keys**: You'll need to set environment variables for Confluent Cloud:
   ```bash
   export TF_VAR_confluent_cloud_api_key="your-api-key"
   export TF_VAR_confluent_cloud_api_secret="your-api-secret"
   ```

### Differences from AWS Version

1. **Private Link Implementation**:
   - Uses Azure Private Endpoints instead of AWS VPC Endpoints
   - Azure Private Link Service aliases instead of VPC Endpoint Service Names
   - Azure Private DNS Zones instead of Route53 hosted zones

2. **Network Security**:
   - Network Security Groups (NSGs) instead of AWS Security Groups
   - NSG association with subnets instead of VPC endpoint security groups

3. **Resource Organization**:
   - Azure Resource Groups for resource organization
   - Azure regions and locations specification

4. **DNS Resolution**:
   - Azure Private DNS Zones with VNet links
   - Simplified DNS record management compared to AWS Route53 zonal records
