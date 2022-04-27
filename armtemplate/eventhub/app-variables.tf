#############################
## Application - Variables ##
#############################


variable "event_app_name" {
  type        = string
  description = "This variable defines the event application name used to build resources"
}

# company name 
variable "resource_group_name" {
  type        = string
  description = "This variable defines the company name used to build resources"
}

# company prefix 
variable "prefix" {
  type        = string
  description = "This variable defines the company name prefix used to build resources"
}

# azure region
variable "location" {
  type        = string
  description = "Azure region where the resource group will be created"
  default     = "us-south-central"

}

# application or company environment
variable "environment" {
  type        = string
  description = "This variable defines the environment to be built"
}


#########################
## Network - Variables ##
#########################

variable "ktest-vnet-cidr" {
  type        = string
  description = "The CIDR of the VNET"
}

variable "ktest-subnet-cidr" {
  type        = string
  description = "The CIDR for the Backoffice subnet"
}



variable "ktest-event-privatelink" {
  type        = string
  description = "Event DNS Private Link"
}


variable "event_hub_namespace_n" {
  default       = "testeventhub12345678"
  description   = "Event hub"
}

variable "event_hub_n" {
  default       = "testeventhub1"
  description   = "Event hubs"
}
