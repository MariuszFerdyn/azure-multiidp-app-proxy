# Deploy a Hybrid connection
```
#!/bin/bash
##az login #--use-device-code

# Define variables
subscriptionId="your-subscription-id"
rely="app-proxy"
resourceGroup="${rely}-rg"
relay="${rely}relay"
location="your-desired-location"
$subscriptionId="your-subscryption-id"
$Enviorment="ContainerAppProxy"


# Set the active subscription
az account set --subscription $subscriptionId

# create resource group
az group create --name $resourceGroup --location $location
# create relay namespace
az relay namespace create -g $resourceGroup --name $relay --location $location
# create the hybrid connection endpoint 'db'
az relay hyco create -g $resourceGroup --namespace-name $relay --name db
# grant the current user "owner" permission
# Create the secrets
az relay hyco authorization-rule create -g $resourceGroup --hybrid-connection-name db --namespace-name $relay -n root --rights Send,Listen

az relay hyco authorization-rule keys list --hybrid-connection-name db --namespace-name $relay -g $resourceGroup -n root
```

# Crate the Container Apps
```
# Prepare env
az extension add --name containerapp --upgrade --allow-preview true
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

# Create Container App Enviorment
az containerapp env create --name $Enviorment --resource-group $ResourceGroup --location $location

# Create a container app by explicitly passing in a Compose configuration file.
az containerapp compose create -g $ResourceGroup --environment $Enviorment --compose-file-path "docker-compose-azure.yml"

# you cannot configure the ingress controller in details for Azure Container Apps directly via a Docker Compose file. Instead, ingress settings must be configured using the Azure CLI.
$CONTAINER_PROXY_NAME="db007"
az containerapp ingress enable --name $CONTAINER_PROXY_NAME --resource-group $ResourceGroup --target-port 8080 --exposed-port 8080 --transport tcp --type internal
```
