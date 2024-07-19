terraform {
  required_version = ">= 0.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.17.0"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.80.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

provider "aws" {
  region = var.region
}


resource "confluent_environment" "staging" {
  display_name = "Staging"
}

resource "confluent_kafka_cluster" "enterprise" {
  display_name = "inventory"
  availability = "MULTI_ZONE"
  cloud        = "AWS"
  region       = var.region
  enterprise {}
  environment {
    id = confluent_environment.staging.id
  }
}

resource "confluent_private_link_attachment" "pla" {
  cloud = "AWS"
  region = var.region
  display_name = "staging-aws-platt"
  environment {
    id = confluent_environment.staging.id
  }
}

module "privatelink" {
  source                   = "./aws-privatelink-endpoint"
  vpc_id                   = var.vpc_id
  privatelink_service_name = confluent_private_link_attachment.pla.aws[0].vpc_endpoint_service_name
  bootstrap                = confluent_kafka_cluster.enterprise.bootstrap_endpoint
  subnets_to_privatelink   = var.subnets_to_privatelink
  dns_domain_name = confluent_private_link_attachment.pla.dns_domain
}

resource "confluent_private_link_attachment_connection" "plac" {
  display_name = "staging-aws-plattc"
  environment {
    id = confluent_environment.staging.id
  }
  aws {
    vpc_endpoint_id = module.privatelink.vpc_endpoint_id
  }

  private_link_attachment {
    id = confluent_private_link_attachment.pla.id
  }
}

resource "confluent_service_account" "app-manager" {
  display_name = "app-manager"
  description  = "Service account to manage 'inventory' Kafka cluster"
}
resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.enterprise.rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager' service account"
  owner {
    id          = confluent_service_account.app-manager.id
    api_version = confluent_service_account.app-manager.api_version
    kind        = confluent_service_account.app-manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.enterprise.id
    api_version = confluent_kafka_cluster.enterprise.api_version
    kind        = confluent_kafka_cluster.enterprise.kind

    environment {
      id = confluent_environment.staging.id
    }
  }
    depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin
  ]
}