# terraform_sql_private_endpoint_azure_

curl -L https://aka.ms/InstallAzureCli | bash


az account list
az account show 
az account list -o table
https://docs.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-show

az account set --subscription 'subscription name or id'
az group list -otable
az group show -n ODL-azureV2-587966
az group show -n resource1

https://www.tutorialspoint.com/how-to-get-the-azure-resource-group-using-azure-cli-in-powershell
az account clear
az logout
![image](https://user-images.githubusercontent.com/102666849/163563286-fd5ad487-5809-4dbf-8871-c47c4e24d41f.png)


terraform init
terraform init -backend-config=backend.conf
terraform plan
terraform apply

Subscription id
az account list

Tenant id
az account tenant list

nc -zvw10  10.50.2.4  22
nmap 10.50.2.2 -Pn -p 144


Create Service Principal
az ad sp create-for-rbac --name "MyApp" --role contributor --scopes /subscriptions/{SubID}/resourceGroups/{ResourceGroup1} 
az ad sp create-for-rbac --name test1 --password "PASSWORD12345"

az ad sp create-for-rbac --name "MyApp" --role contributor --scopes /subscriptions/fbaf93c1-1423-4bba-9ffa-c917f5e38d92/resourceGroups/resource1

OR
az ad sp create-for-rbac --name {appId} --password "{strong password}"
az role assignment create --assignee <objectID> --role Contributor
az login --service-principal -u <appid> --password {password-or-path-to-cert} --tenant {tenant}
https://geeksarray.com/blog/get-azure-subscription-tenant-client-id-client-secret
https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-view-managed-identity-service-principal-portal
https://www.ibm.com/docs/en/netezza?topic=SSTNZ3/com.ibm.ips.doc/postgresql/admin/create_service_principal_azure.html
https://jiasli.github.io/azure-notes/aad/Service-Principal-portal.html

![image](https://user-images.githubusercontent.com/102666849/163563295-ea821f4f-ee3c-4a50-9984-0d00f3481da4.png)
