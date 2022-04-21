#############################
## Application - Variables ##
#############################

# app name 
variable "app_name" {
  type        = string
  description = "This variable defines the application name used to build resources"
}

# company name 
variable "company" {
  type        = string
  description = "This variable defines the company name used to build resources"
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
  default     = "West US"
}

# application or company environment
variable "environment" {
  type        = string
  description = "This variable defines the environment to be built"
}


#########################
## Network - Variables ##
#########################

variable "kopi-vnet-cidr" {
  type        = string
  description = "The CIDR of the VNET"
}

variable "kopi-db-subnet-cidr" {
  type        = string
  description = "The CIDR for the Backoffice subnet"
}

variable "kopi-private-dns" {
  type        = string
  description = "The private DNS name"
}

variable "kopi-dns-privatelink" {
  type        = string
  description = "SQL DNS Private Link"
}


############################
## SQL Server - Variables ##
############################

variable "kopi-sql-admin-username" {
  description = "Username for SQL Server administrator account"
  type        = string
  default     = "sqladmin"
}

variable "kopi-sql-admin-password" {
  description = "Password for SQL Server administrator account"
  type        = string
  default     = "S3cur3Acc3ss67"
}


