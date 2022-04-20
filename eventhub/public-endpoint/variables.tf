variable "resource_group_name" {
  default       = "rg"
  description   = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "resource_group_location" {
  default       = "East US"
  description   = "Location of the resource group."
}


variable "event_hub_namespace_n" {
  default       = "testeventhub12345678"
  description   = "Event hub"
}



variable "event_hub_n" {
  default       = "testeventhub1"
  description   = "Event hubs"
}
