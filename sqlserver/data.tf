data "azurerm_subscription" "current" {
}


data "azurerm_resource_group" "ktest-rg" {
  name     = var.resource_group_name
}
