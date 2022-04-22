
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
  name                = "${var.prefix}-${var.environment}-${var.app_name}-vnet"
  address_space       = [var.ktest-vnet-cidr]
  location            = data.azurerm_resource_group.ktest-rg.location
  resource_group_name = data.azurerm_resource_group.ktest-rg.name

  tags = {
    environment = var.environment
  }
}

# Create a DB subnet
resource "azurerm_subnet" "ktest-db-subnet" {
  name                 = "${var.prefix}-${var.environment}-${var.app_name}-db-subnet"
  address_prefixes     = [var.ktest-db-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.ktest-vnet.name
  resource_group_name  = data.azurerm_resource_group.ktest-rg.name
  enforce_private_link_endpoint_network_policies = true
}



########################
## Network - Endpoint ##
########################

# Create a DB Private Endpoint
resource "azurerm_private_endpoint" "ktest-db-endpoint" {
  depends_on = [azurerm_mssql_server.ktest-sql-server]

  name                = "${var.prefix}-${var.environment}-${var.app_name}-db-endpoint"
  location            = data.azurerm_resource_group.ktest-rg.location
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
  subnet_id           = azurerm_subnet.ktest-db-subnet.id
  private_service_connection {
    name                           = "${var.prefix}-${var.environment}-${var.app_name}-db-endpoint"
    is_manual_connection           = "false"
    private_connection_resource_id = azurerm_mssql_server.ktest-sql-server.id
    subresource_names              = ["sqlServer"]
  }
}

# DB Private Endpoint Connecton
data "azurerm_private_endpoint_connection" "ktest-endpoint-connection" {
  depends_on = [azurerm_private_endpoint.ktest-db-endpoint]
  name                = azurerm_private_endpoint.ktest-db-endpoint.name
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
}


# Create a Private DNS to VNET link
resource "azurerm_private_dns_zone_virtual_network_link" "dns-zone-to-vnet-link" {
  name                  = "${var.prefix}-${var.environment}-${var.app_name}-db-vnet-link"
  resource_group_name   = data.azurerm_resource_group.ktest-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.ktest-endpoint-dns-private-zone.name
  virtual_network_id    = azurerm_virtual_network.ktest-vnet.id
}

###################
## Network - DNS ##
###################


# Create a DB Private DNS A Record
resource "azurerm_private_dns_a_record" "ktest-endpoint-dns-a-record" {
  depends_on = [azurerm_mssql_server.ktest-sql-server]
  name                = lower(azurerm_mssql_server.ktest-sql-server.name)
  zone_name           = azurerm_private_dns_zone.ktest-endpoint-dns-private-zone.name
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.ktest-endpoint-connection.private_service_connection.0.private_ip_address]
}

# Create a DB Private DNS Zone
resource "azurerm_private_dns_zone" "ktest-endpoint-dns-private-zone" {
  name                = "${var.ktest-dns-privatelink}.database.windows.net"
  resource_group_name = data.azurerm_resource_group.ktest-rg.name
}

#######################
## SQL Server - Main ##
#######################

# Create the SQL Server 
resource "azurerm_mssql_server" "ktest-sql-server" {
  name                          = "${var.prefix}-${var.environment}-${var.app_name}-sql-server" # NOTE: needs to be globally unique
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

