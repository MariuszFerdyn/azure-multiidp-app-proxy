# Azure Hybrid Application Proxy - Scalable reverse proxy solution with flexible identity provider support

The Azure Hybrid Application Proxy project aims to create a highly scalable and flexible reverse proxy solution built on Azure App Service and leveraging Azure App Service Hybrid Connections. The key objectives are:

1. **Massive Scale**: Overcome the 750 requests per second limit of the current Azure Application Proxy offering to enable massive scale.

2. **Flexible Identity Provider Support**: Extend identity provider support beyond Azure Active Directory to also integrate with Azure AD B2C and potentially other IDPs in the future. This will allow applications to authenticate users from various identity sources.

3. **Azure App Service Foundation**: Utilize Azure App Service as the core hosting platform to gain benefits such as auto-scaling, high availability, and managed runtimes.

4. **Secure Hybrid Connectivity**: Implement Azure App Service Hybrid Connections to securely connect the proxy to on-premises web applications without requiring opening inbound ports on the firewall.

5. **Pure Reverse Proxy**: Act as a pure reverse proxy solution, securely relaying authenticated requests to backend applications. The proxy itself will not implement any application logic.

6. **NGINX-based Ingress Controller**: Utilize the well-known Ingress Controller based on NGINX to handle incoming traffic, load balancing, and routing requests to the appropriate backend services.

# Deploy Azure App Service
```
#!/bin/bash
##az login #--use-device-code

# Define variables
subscriptionId="your-subscription-id"
webAppName="hybrid-proxy"
resourceGroupName="${webAppName}-rg"
appServicePlan="${webAppName}plan"
containerImage="docker.io/mafamafa/nginx-container-proxy:202502022107"
SKU="B1"
location="your-desired-location"

# Set the active subscription
az account set --subscription "$subscriptionId"

# Create the resource group
az group create \
  --name "$resourceGroupName" \
  --location "$location"

# Create the App Service plan
az appservice plan create \
  --name "$appServicePlan" \
  --resource-group "$resourceGroupName" \
  --sku "$SKU" \
  --is-linux \
  --location "$location"

# Create the Web App
az webapp create \
  --resource-group "$resourceGroupName" \
  --plan "$appServicePlan" \
  --name "${webAppName}-appservice" \
  --deployment-container-image-name "$containerImage"
```

# Set environment variables for the Web App - this is the destination address
```
az webapp config appsettings set \
  --resource-group "$resourceGroupName" \
  --name "${webAppName}-appservice" \
  --settings \
    DEFAULT_OVERRIDE_HOST=emailmarketing.fast-sms.net \
    DEFAULT_OVERRIDE_PORT=80 \
    DEFAULT_OVERRIDE_PROTOCOL=http \
    DEFAULT_OVERRIDE_IP=93.157.100.46
```
At this moment you can browese the site and it will be proxied to the sample my old site.

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
# Create Hybrid connection
1. Open created App Service
2. Go to Networking
3. Click Hybrid connections
4. Click Create new hybrid connection as follow and click ok:
5. Open the newly crated connection and copy the Gateway Connection String
5. Log in using RDP to the machine and install the agent from: https://go.microsoft.com/fwlink/?linkid=841308
6. Launch the Hybrid Connection Manager UI
7. Click Enter Manually and put the copied Gateway Connection string
8. Click refresh it should be connected
9. If it is not connected issue in PowerShell ```restart-service HybridConnectionManager```
