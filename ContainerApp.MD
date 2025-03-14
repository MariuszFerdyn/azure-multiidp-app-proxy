# Deploy a Hybrid connection
```
#!/bin/bash
##az login #--use-device-code

# Define variables
rely="app-proxy"
resourceGroup="${rely}-rg"
relay="${rely}relay"
location="your-desired-location"
subscriptionId="your-subscryption-id"
Enviorment="ContainerAppProxy"


# Set the active subscription
az account set --subscription $subscriptionId

# create resource group
az group create --name $resourceGroup --location $location
# create relay namespace
az relay namespace create -g $resourceGroup --name $relay --location $location
# create the hybrid connection endpoint 'db'
az relay hyco create -g $resourceGroup --namespace-name $relay --name db

# Create the secrets
az relay hyco authorization-rule create -g $resourceGroup --hybrid-connection-name db --namespace-name $relay -n root --rights Send Listen

az relay hyco authorization-rule keys list --hybrid-connection-name db --namespace-name $relay -g $resourceGroup -n root
```
# Install the Windows VM for test purpose
```
adminUsername="adminuser"
adminPassword="YourPassword123!"
vmSize="Standard_B2s"
az vm create --resource-group $resourceGroupName \
    --name "${webAppName}-vm" \
    --image Win2019Datacenter \
    --public-ip-sku Standard \
    --admin-username $adminUsername --admin-password $adminPassword --size $vmSize --location $location
```
## Install IIS and Sample Pages on VM
```
az vm extension set \
  --resource-group $resourceGroupName \
  --vm-name "${webAppName}-vm" \
  --name CustomScriptExtension \
  --publisher Microsoft.Compute \
  --version 1.10 \
  --settings '{
    "fileUris": ["https://raw.githubusercontent.com/MariuszFerdyn/azure-multiidp-app-proxy/refs/heads/main/scripts/Install_IIS_and_SamplePages.ps1"],
    "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File Install_IIS_and_SamplePages.ps1"
  }'
```
## Install azbridge
Install [https://github.com/Azure/azure-relay-bridge/releases - download unzip](https://github.com/Azure/azure-relay-bridge/releases)

## On server machine with website
create file with content server.config:
```
RemoteForward :
   - RelayName: zzzz
     Host: 127.0.0.1
     PortName: http
     HostPort: 80
     ConnectionString: Endpoint=sb://finalproxy.servicebus.windows.net/;SharedAccessKeyName=finalproxy;SharedAccessKey=xxxx=;EntityPath=yyyy

LogLevel: INFO
```
## Start azbridge on the server
Execute:
```
azbridge -f .\server.config
```

# Crate the Container Apps
Modify docker-compose-azure.yml file according to the created Hybrid connection.
```
# Prepare env
az extension add --name containerapp --upgrade --allow-preview true
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

# Create Container App Enviorment
az containerapp env create --name $Enviorment --resource-group $resourceGroup --location $location

# Create a container app by explicitly passing in a Compose configuration file.
az containerapp compose create -g $resourceGroup --environment $Enviorment --compose-file-path "docker-compose-azure.yml"

# you cannot configure the ingress controller in details for Azure Container Apps directly via a Docker Compose file. Instead, ingress settings must be configured using the Azure CLI.
az containerapp ingress enable --name azbridge --resource-group $resourceGroup --target-port 8181 --expos
ed-port 8181 --transport tcp --type internal
```

# Enjoy Container App Features
- Authentication with multiple IDP.
- SSL Offloading is fully operational.
- Autoscaling for peak performance is live. You can autoscale/scale up the containers for better performance.
- Flexible Identity Provider Support: Simply authenticate against Entra ID and many other identity providers.
- Even publish the site on the internet from your laptop.
- Protect application with Azure Application Gateway with WAF

## For the best performane you can expose application without NGINX 