output "resource-ids" {
  value = <<-EOT
  Environment ID:   ${confluent_environment.staging.id}
  
  === DEDICATED CLUSTER ===
  Kafka Cluster ID: ${confluent_kafka_cluster.dedicated.id}
  Cluster Name: ${confluent_kafka_cluster.dedicated.display_name}

  Service Accounts and their Kafka API Keys:
  ${confluent_service_account.app-manager.display_name}:                     ${confluent_service_account.app-manager.id}
  ${confluent_service_account.app-manager.display_name}'s Kafka API Key:     "${confluent_api_key.app-manager-kafka-api-key.id}"
  ${confluent_service_account.app-manager.display_name}'s Kafka API Secret:  "${confluent_api_key.app-manager-kafka-api-key.secret}"

  === ENTERPRISE CLUSTER ===
  Kafka Cluster ID: ${confluent_kafka_cluster.enterprise.id}
  Cluster Name: ${confluent_kafka_cluster.enterprise.display_name}

  Service Accounts and their Kafka API Keys:
  ${confluent_service_account.enterprise-app-manager.display_name}:                     ${confluent_service_account.enterprise-app-manager.id}
  ${confluent_service_account.enterprise-app-manager.display_name}'s Kafka API Key:     "${confluent_api_key.enterprise-app-manager-kafka-api-key.id}"
  ${confluent_service_account.enterprise-app-manager.display_name}'s Kafka API Secret:  "${confluent_api_key.enterprise-app-manager-kafka-api-key.secret}"

  ${confluent_service_account.enterprise-app-producer.display_name}:                    ${confluent_service_account.enterprise-app-producer.id}
  ${confluent_service_account.enterprise-app-producer.display_name}'s Kafka API Key:    "${confluent_api_key.enterprise-app-producer-kafka-api-key.id}"
  ${confluent_service_account.enterprise-app-producer.display_name}'s Kafka API Secret: "${confluent_api_key.enterprise-app-producer-kafka-api-key.secret}"

  ${confluent_service_account.enterprise-app-consumer.display_name}:                    ${confluent_service_account.enterprise-app-consumer.id}
  ${confluent_service_account.enterprise-app-consumer.display_name}'s Kafka API Key:    "${confluent_api_key.enterprise-app-consumer-kafka-api-key.id}"
  ${confluent_service_account.enterprise-app-consumer.display_name}'s Kafka API Secret: "${confluent_api_key.enterprise-app-consumer-kafka-api-key.secret}"

  === NETWORKING ===
  Azure Private Endpoint ID: ${module.privatelink.private_endpoint_id}
  Private IP Address: ${module.privatelink.private_ip_address}
  DNS Zone Name: ${module.privatelink.dns_zone_name}

  EOT
  sensitive = true
}
