resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_eventhub_namespace" "event_namespace" {
  name                = var.event_hub_namespace_n
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "Development"
  }
}

resource "azurerm_eventhub" "eventhub1" {
  name                = var.event_hub_n
  namespace_name      = azurerm_eventhub_namespace.event_namespace.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}





