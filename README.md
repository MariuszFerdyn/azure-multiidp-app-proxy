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
containerImage="mafamafa/nginx-container-proxy:202502022107"
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
