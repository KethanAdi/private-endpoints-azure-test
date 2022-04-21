####################
# Common Variables #
####################
app_name    = "sql"
company     = "kopicloud"
prefix      = "kopi"
environment = "dev"
location    = "West US"
resource_group_name = "resource-group"

##################
# Authentication #
##################
azure-subscription-id = "fbaf93c1-1423-4bba-9ffa-c917f5e38d92"
azure-client-id       = "3e2d03bc-ba8c-44e7-9ac6-18a65c9c553d"
azure-client-secret   = "iUH7Q~WUJJ13JUVzNnDVNQWvK-MhaQuqb.KRA"
azure-tenant-id       = "74d1b21c-94a8-4cb3-85a8-3abeb1fb449e"

###########
# Network #
###########
kopi-vnet-cidr       = "10.50.0.0/16"
kopi-db-subnet-cidr  = "10.50.2.0/24"
kopi-private-dns     = "kopicloud.lan"
kopi-dns-privatelink = "kopidb"
#sec id test2
#1b96856d-e1eb-4cc1-906f-2373495d6135
#sec value
#iUH7Q~WUJJ13JUVzNnDVNQWvK-MhaQuqb.KRA

#[root@eef51d68f41c terraform-azure-sqlserver-private-endpoint]# az ad sp create-for-rbac --name "MyApp" --role contributor --scopes /subscriptions/fbaf93c1-1423-4bba-9ffa-c917f5e38d92/resourceGroups/resource1
#{
#  "appId": "3e2d03bc-ba8c-44e7-9ac6-18a65c9c553d",
#  "displayName": "MyApp",
#  "password": "431Yr9-fxf3u7WJy3arfNwfQU7dFnno~Jy",
#  "tenant": "74d1b21c-94a8-4cb3-85a8-3abeb1fb449e"
#}
#secid rbac
#d6377834-924f-4473-89c4-d57e8f033f1f
#sec value
#
