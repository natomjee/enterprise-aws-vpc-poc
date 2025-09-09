data "azurerm_resource_group" "privatelink" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "privatelink" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "privatelink" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.resource_group_name
}

locals {
  bootstrap_prefix = split(".", var.bootstrap)[0]
}

# Network Security Group with rules for Confluent Cloud
resource "azurerm_network_security_group" "privatelink" {
  name                = "ccloud-privatelink-${local.bootstrap_prefix}-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.privatelink.name

  # Allow HTTP traffic (optional, for redirect support)
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = data.azurerm_virtual_network.privatelink.address_space[0]
    destination_address_prefix = "*"
  }

  # Allow HTTPS traffic
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = data.azurerm_virtual_network.privatelink.address_space[0]
    destination_address_prefix = "*"
  }

  # Allow Kafka traffic
  security_rule {
    name                       = "AllowKafka"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9092"
    source_address_prefix      = data.azurerm_virtual_network.privatelink.address_space[0]
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Confluent-PrivateLink"
  }
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "privatelink" {
  subnet_id                 = data.azurerm_subnet.privatelink.id
  network_security_group_id = azurerm_network_security_group.privatelink.id
}

# Private Endpoint for Confluent Cloud
resource "azurerm_private_endpoint" "privatelink" {
  name                = "ccloud-privatelink-${local.bootstrap_prefix}-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.privatelink.name
  subnet_id           = data.azurerm_subnet.privatelink.id

  private_service_connection {
    name                           = "ccloud-privatelink-${local.bootstrap_prefix}-psc"
    private_connection_resource_alias = var.privatelink_service_name
    is_manual_connection           = true
    request_message                = "Private Link connection for Confluent Cloud"
  }

  tags = {
    Environment = "Confluent-PrivateLink"
  }
}

# Private DNS Zone for Confluent Cloud
resource "azurerm_private_dns_zone" "privatelink" {
  name                = var.dns_domain_name
  resource_group_name = data.azurerm_resource_group.privatelink.name

  tags = {
    Environment = "Confluent-PrivateLink"
  }
}

# Link DNS Zone to Virtual Network
resource "azurerm_private_dns_zone_virtual_network_link" "privatelink" {
  name                  = "ccloud-privatelink-${local.bootstrap_prefix}-dns-link"
  resource_group_name   = data.azurerm_resource_group.privatelink.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink.name
  virtual_network_id    = data.azurerm_virtual_network.privatelink.id
  registration_enabled  = false

  tags = {
    Environment = "Confluent-PrivateLink"
  }
}

# DNS A record for the private endpoint
resource "azurerm_private_dns_a_record" "privatelink" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.privatelink.name
  resource_group_name = data.azurerm_resource_group.privatelink.name
  ttl                 = 60
  records             = [azurerm_private_endpoint.privatelink.private_service_connection[0].private_ip_address]

  tags = {
    Environment = "Confluent-PrivateLink"
  }
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.privatelink.id
}

output "private_ip_address" {
  value = azurerm_private_endpoint.privatelink.private_service_connection[0].private_ip_address
}

output "dns_zone_name" {
  value = azurerm_private_dns_zone.privatelink.name
}
