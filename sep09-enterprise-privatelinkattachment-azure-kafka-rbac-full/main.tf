terraform {
  required_version = ">= 0.14.0"
  required_providers {
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

resource "confluent_kafka_cluster" "enterprise" {
  display_name = "gruppy"
  availability = "MULTI_ZONE"
  cloud        = "AZURE"
  region       = var.region
  enterprise {}
  environment {
    id = var.confluent_environment_id
  }
}

// 'sep09-app-manager' service account is required in this configuration to create 'orders' topic and assign roles
// to 'sep09-app-producer' and 'sep09-app-consumer' service accounts.
resource "confluent_service_account" "app-manager" {
  display_name = "sep09-app-manager"
  description  = "Service account to manage 'inventory' Kafka cluster"
}

resource "confluent_role_binding" "app-manager-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.enterprise.rbac_crn
}

resource "confluent_api_key" "app-manager-kafka-api-key" {
  display_name = "sep09-app-manager-kafka-api-key"
  description  = "Kafka API Key that is owned by 'sep09-app-manager' service account"
  disable_wait_for_ready = false

  # Set `disable_wait_for_ready` to `false` (default) when running from within private network with connectivity to Kafka REST API
  # This allows Terraform to validate API key creation by listing topics

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
      id = var.confluent_environment_id
    }
  }

  # The goal is to ensure that confluent_role_binding.app-manager-kafka-cluster-admin is created before
  # confluent_api_key.app-manager-kafka-api-key is used to create instances of
  # confluent_kafka_topic resource.
  depends_on = [
    confluent_role_binding.app-manager-kafka-cluster-admin
  ]
}

resource "confluent_service_account" "app-consumer" {
  display_name = "sep09-app-consumer"
  description  = "Service account to consume from 'orders' topic of 'inventory' Kafka cluster"
}

resource "confluent_api_key" "app-consumer-kafka-api-key" {
  display_name = "sep09-app-consumer-kafka-api-key"
  description  = "Kafka API Key that is owned by 'sep09-app-consumer' service account"
  disable_wait_for_ready = false

  # Set `disable_wait_for_ready` to `false` (default) when running from within private network with connectivity to Kafka REST API
  # This allows Terraform to validate API key creation by listing topics

  owner {
    id          = confluent_service_account.app-consumer.id
    api_version = confluent_service_account.app-consumer.api_version
    kind        = confluent_service_account.app-consumer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.enterprise.id
    api_version = confluent_kafka_cluster.enterprise.api_version
    kind        = confluent_kafka_cluster.enterprise.kind

    environment {
      id = var.confluent_environment_id
    }
  }
}

resource "confluent_service_account" "app-producer" {
  display_name = "sep09-app-producer"
  description  = "Service account to produce to 'orders' topic of 'inventory' Kafka cluster"
}

resource "confluent_api_key" "app-producer-kafka-api-key" {
  disable_wait_for_ready = false

  # Set `disable_wait_for_ready` to `false` (default) when running from within private network with connectivity to Kafka REST API
  # This allows Terraform to validate API key creation by listing topics

  display_name = "sep09-app-producer-kafka-api-key"
  description  = "Kafka API Key that is owned by 'sep09-app-producer' service account"
  owner {
    id          = confluent_service_account.app-producer.id
    api_version = confluent_service_account.app-producer.api_version
    kind        = confluent_service_account.app-producer.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.enterprise.id
    api_version = confluent_kafka_cluster.enterprise.api_version
    kind        = confluent_kafka_cluster.enterprise.kind

    environment {
      id = var.confluent_environment_id
    }
  }
}
