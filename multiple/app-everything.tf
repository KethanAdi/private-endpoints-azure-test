
###########################
## Azure Provider - Main ##
###########################

# Define Terraform provider
terraform {
  required_version = ">= 0.13"
}

# Configure the Azure provider
provider "azurerm" {
  environment = "public"
  version     = ">= 2.7.0"
  features {}
  #subscription_id = var.azure-subscription-id
  #client_id       = var.azure-client-id
  #client_secret   = var.azure-client-secret
  #tenant_id       = var.azure-tenant-id
  skip_provider_registration = true

}


####################
## Network - Main ##
####################

# Create a resource group
#resource "data.azurerm_resource_group" "ktest-rg" {
#  name     = var.resource_group_name
#  location = var.location
#
#  tags = {
#    environment = var.environment
#  }
#}

# Create the VNET
resource "azurerm_virtual_network" "ktest-vnet" {
  name                = "${var.prefix}-${var.environment}-${var.sql_app_name}-vnet"
  address_space       = [var.ktest-vnet-cidr]
  location            = data.azurerm_resource_group.ktest-rg.location
  resource_group_name = data.azurerm_resource_group.ktest-rg.name

  tags = {
    environment = var.environment
  }
}

# Create a DB subnet
resource "azurerm_subnet" "ktest-subnet" {
  name                 = "${var.prefix}-${var.environment}-${var.sql_app_name}-subnet"
  address_prefixes     = [var.ktest-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.ktest-vnet.name
  resource_group_name  = data.azurerm_resource_group.ktest-rg.name
  enforce_private_link_endpoint_network_policies = true
}


###################
## Network - DNS ##
###################

# Create a Private DNS Zone
#resource "azurerm_private_dns_zone" "ktest-private-dns" {
#  name                = var.ktest-private-dns
#  resource_group_name = data.azurerm_resource_group.ktest-rg.name
#}

# Link the Private DNS Zone with the VNET
#resource "azurerm_private_dns_zone_virtual_network_link" "ktest-private-dns-link" {
#  name                  = "${var.prefix}-${var.environment}-${var.sql_app_name}-vnet"
#  resource_group_name   = data.azurerm_resource_group.ktest-rg.name
#  private_dns_zone_name = azurerm_private_dns_zone.ktest-private-dns.name
#  virtual_network_id    = azurerm_virtual_network.ktest-vnet.id
#}


########################
## Network - DB Endpoint ##
########################

# Create a DB Private Endpoint
resource "azurerm_private_endpoint" "ktest-db-endpoint" {
  depends_on = [azurerm_mssql_server.ktest-sql-server]
  name                = "${var.prefix}-${var.environment}-${var.sql_app_name}-db-endpoint"
  location            = data.azurerm_resource_group.ktest-rg.location
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
  subnet_id           = azurerm_subnet.ktest-subnet.id

  private_service_connection {
    name                           = "${var.prefix}-${var.environment}-${var.sql_app_name}-db-endpoint"
    is_manual_connection           = "false"
    private_connection_resource_id = azurerm_mssql_server.ktest-sql-server.id
    subresource_names              = ["sqlServer"]
  }
}

# DB Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "ktest-db-endpoint-connection" {
  depends_on = [azurerm_private_endpoint.ktest-db-endpoint]
  name                = azurerm_private_endpoint.ktest-db-endpoint.name
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
}

# Create a DB Private DNS A Record
resource "azurerm_private_dns_a_record" "ktest-endpoint-db-dns-a-record" {
  depends_on = [azurerm_mssql_server.ktest-sql-server]
  name                = lower(azurerm_mssql_server.ktest-sql-server.name)
  zone_name           = azurerm_private_dns_zone.ktest-endpoint-db-dns-private-zone.name
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.ktest-db-endpoint-connection.private_service_connection.0.private_ip_address]
}

# Create a DB Private DNS Zone
resource "azurerm_private_dns_zone" "ktest-endpoint-db-dns-private-zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
}

# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "db-dns-zone-to-vnet-link" {
  name                  = "${var.prefix}-${var.environment}-${var.sql_app_name}-db-vnet-link"
  resource_group_name   = data.azurerm_resource_group.ktest-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.ktest-endpoint-db-dns-private-zone.name
  virtual_network_id    = azurerm_virtual_network.ktest-vnet.id
}


#######################
## SQL Server - Main ##
#######################

# Create the SQL Server
resource "azurerm_mssql_server" "ktest-sql-server" {
  name                          = "${var.prefix}-${var.environment}-${var.sql_app_name}-sql-server" # NOTE: needs to be globally unique
  resource_group_name           = data.azurerm_resource_group.ktest-rg.name
  location                      = data.azurerm_resource_group.ktest-rg.location
  version                       = "12.0"
  administrator_login           = var.ktest-sql-admin-username
  administrator_login_password  = var.ktest-sql-admin-password
  public_network_access_enabled = false

  tags = {
    environment = var.environment
  }
}

# Create a the SQL database
resource "azurerm_sql_database" "ktest-sql-db" {
  depends_on = [azurerm_mssql_server.ktest-sql-server]
  name                = "ktest-db"
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
  location            = data.azurerm_resource_group.ktest-rg.location
  server_name         = azurerm_mssql_server.ktest-sql-server.name

  tags = {
    environment = var.environment
  }
}



########################
## Network - Event HUB Endpoint ##
########################

# Create a event Private Endpoint
resource "azurerm_private_endpoint" "ktest-event-endpoint" {
#  depends_on = [azurerm_eventhub_namespace.event_namespace1]
  name                = "${var.prefix}-${var.environment}-${var.event_app_name}-event-endpoint"
  location            = data.azurerm_resource_group.ktest-rg.location
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
  subnet_id           = azurerm_subnet.ktest-subnet.id

  private_service_connection {
    name                           = "${var.prefix}-${var.environment}-${var.event_app_name}-event-endpoint"
    is_manual_connection           = "false"
    private_connection_resource_id = azurerm_eventhub_namespace.event_namespace1.id
    subresource_names              = ["namespace"]
  }
}

# event Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "ktest-event-endpoint-connection" {
  depends_on = [azurerm_private_endpoint.ktest-event-endpoint]
  name                = azurerm_private_endpoint.ktest-event-endpoint.name
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
}

# Create a event Private DNS A Record
resource "azurerm_private_dns_a_record" "ktest-event-endpoint-dns-a-record" {
  depends_on = [azurerm_eventhub_namespace.event_namespace1]
  name                = lower(azurerm_eventhub_namespace.event_namespace1.name)
  zone_name           = azurerm_private_dns_zone.ktest-endpoint-event-dns-private-zone.name
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.ktest-event-endpoint-connection.private_service_connection.0.private_ip_address]
}

# Create a event Private DNS Zone
resource "azurerm_private_dns_zone" "ktest-endpoint-event-dns-private-zone" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
}

# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "event-dns-zone-to-vnet-link" {
  name                  = "${var.prefix}-${var.environment}-${var.event_app_name}-event-vnet-link"
  resource_group_name   = data.azurerm_resource_group.ktest-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.ktest-endpoint-event-dns-private-zone.name
  virtual_network_id    = azurerm_virtual_network.ktest-vnet.id
}


#Event hub
resource "azurerm_eventhub_namespace" "event_namespace1" {
  depends_on = [azurerm_subnet.ktest-subnet]
  name                = var.event_hub_namespace_n
  location            = data.azurerm_resource_group.ktest-rg.location
  resource_group_name =data.azurerm_resource_group.ktest-rg.name
  sku                 = "Standard"
  capacity            = 1
  network_rulesets  = [{
    default_action       = "Allow"
    trusted_service_access_enabled = false
    virtual_network_rule = [{
        subnet_id = azurerm_subnet.ktest-subnet.id
        ignore_missing_virtual_network_service_endpoint = true
    }]
    ip_rule = [
     {
        ip_mask = "0.0.0.0/0"
        action  = "Allow"
     }]
  }  ]
  tags = {
    environment = "Development"
  }
}

resource "azurerm_eventhub" "event_hub1" {
  depends_on = [azurerm_eventhub_namespace.event_namespace1]
  name                = var.event_hub_n
  namespace_name      = azurerm_eventhub_namespace.event_namespace1.name
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
  partition_count     = 2
  message_retention   = 1
}
