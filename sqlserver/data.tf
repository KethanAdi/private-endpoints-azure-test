data "azurerm_subscription" "current" {
}


data "azurerm_resource_group" "kopi-rg" {
  name     = var.resource_group_name
  location = var.location
}
