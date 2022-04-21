
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
#resource "azurerm_resource_group" "kopi-rg" {
#  name     = var.resource_group_name
#  location = var.location
#
#  tags = {
#    environment = var.environment
#  }
#}

# Create the VNET
resource "azurerm_virtual_network" "kopi-vnet" {
  name                = "${var.prefix}-${var.environment}-${var.app_name}-vnet"
  address_space       = [var.kopi-vnet-cidr]
  location            = azurerm_resource_group.kopi-rg.location
  resource_group_name = azurerm_resource_group.kopi-rg.name

  tags = {
    environment = var.environment
  }
}

# Create a DB subnet
resource "azurerm_subnet" "kopi-db-subnet" {
  name                 = "${var.prefix}-${var.environment}-${var.app_name}-db-subnet"
  address_prefixes     = [var.kopi-db-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.kopi-vnet.name
  resource_group_name  = azurerm_resource_group.kopi-rg.name
  enforce_private_link_endpoint_network_policies = true
}


###################
## Network - DNS ##
###################

# Create a Private DNS Zone
resource "azurerm_private_dns_zone" "kopi-private-dns" {
  name                = var.kopi-private-dns
  resource_group_name = azurerm_resource_group.kopi-rg.name
}

# Link the Private DNS Zone with the VNET
resource "azurerm_private_dns_zone_virtual_network_link" "kopi-private-dns-link" {
  name                  = "${var.prefix}-${var.environment}-${var.app_name}-vnet"
  resource_group_name   = azurerm_resource_group.kopi-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kopi-private-dns.name
  virtual_network_id    = azurerm_virtual_network.kopi-vnet.id
}

# Create a DB Private DNS Zone
resource "azurerm_private_dns_zone" "kopi-endpoint-dns-private-zone" {
  name                = "${var.kopi-dns-privatelink}.database.windows.net"
  resource_group_name = azurerm_resource_group.kopi-rg.name
}

########################
## Network - Endpoint ##
########################

# Create a DB Private Endpoint
resource "azurerm_private_endpoint" "kopi-db-endpoint" {
  depends_on = [azurerm_mssql_server.kopi-sql-server]

  name                = "${var.prefix}-${var.environment}-${var.app_name}-db-endpoint"
  location            = azurerm_resource_group.kopi-rg.location
  resource_group_name = azurerm_resource_group.kopi-rg.name
  subnet_id           = azurerm_subnet.kopi-db-subnet.id

  private_service_connection {
    name                           = "${var.prefix}-${var.environment}-${var.app_name}-db-endpoint"
    is_manual_connection           = "false"
    private_connection_resource_id = azurerm_mssql_server.kopi-sql-server.id
    subresource_names              = ["sqlServer"]
  }
}

# DB Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "kopi-endpoint-connection" {
  depends_on = [azurerm_private_endpoint.kopi-db-endpoint]

  name                = azurerm_private_endpoint.kopi-db-endpoint.name
  resource_group_name = azurerm_resource_group.kopi-rg.name
}

# Create a DB Private DNS A Record
resource "azurerm_private_dns_a_record" "kopi-endpoint-dns-a-record" {
  depends_on = [azurerm_mssql_server.kopi-sql-server]

  name                = lower(azurerm_mssql_server.kopi-sql-server.name)
  zone_name           = azurerm_private_dns_zone.kopi-endpoint-dns-private-zone.name
  resource_group_name = azurerm_resource_group.kopi-rg.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.kopi-endpoint-connection.private_service_connection.0.private_ip_address]
}

# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "dns-zone-to-vnet-link" {
  name                  = "${var.prefix}-${var.environment}-${var.app_name}-db-vnet-link"
  resource_group_name   = azurerm_resource_group.kopi-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.kopi-endpoint-dns-private-zone.name
  virtual_network_id    = azurerm_virtual_network.kopi-vnet.id
}


#######################
## SQL Server - Main ##
#######################

# Create the SQL Server 
resource "azurerm_mssql_server" "kopi-sql-server" {
  name                          = "${var.prefix}-${var.environment}-${var.app_name}-sql-server" # NOTE: needs to be globally unique
  resource_group_name           = azurerm_resource_group.kopi-rg.name
  location                      = azurerm_resource_group.kopi-rg.location
  version                       = "12.0"
  administrator_login           = var.kopi-sql-admin-username
  administrator_login_password  = var.kopi-sql-admin-password
  public_network_access_enabled = false

  tags = {
    environment = var.environment
  }
}

# Create a the SQL database 
resource "azurerm_sql_database" "kopi-sql-db" {
  depends_on = [azurerm_mssql_server.kopi-sql-server]

  name                = "kopi-db"
  resource_group_name = azurerm_resource_group.kopi-rg.name
  location            = azurerm_resource_group.kopi-rg.location
  server_name         = azurerm_mssql_server.kopi-sql-server.name

  tags = {
    environment = var.environment
  }
}

