Results for a single instance of AppService (Premium v3 P1mv3). The test was conducted with 20 users on each of the 8 instances, totaling 160 users continuously browsing the site. Below is the image illustrating the results:

![AppService1Instance-20usersx8](media/AppService1Instance-20usersx8.png)


Container Apps configured as follows: ContainerApp with 2 vCPU/4GB RAM ---->>>> ContainerAPP with azbridge 2 vCPU/4GB RAM --->>> Service Bus --->>> WebServer. This can be scalled to zero, so can be totally for free. There is also free tier. The test was conducted with 50 users on each of the 10 instances, totaling 500 users continuously browsing the site.

![ContainerAppsWithNginxAzbridge](media/ContainerAppsWithNginxAzbridge.png)

Container Apps configured as follows: ContainerApp with 2 vCPU/4GB RAM (autoscaling 0-15) ---->>>> ContainerAPP with azbridge 2 vCPU/4GB RAM --->>> Service Bus --->>> WebServer. The test was conducted with 50 users on each of the 10 instances, totaling 500 users continuously browsing the site.

![ContainerAppsAutoScallingWithNginxAzbridge](media/ContainerAppsAutoScallingWithNginxAzbridge.png)


You can reconfigure the Ingress controller to External and HTTPS for the azbridge container and route traffic directly to your web app. This configuration provides the best performance - 4266 requests/s per container, compared to Azure App Proxy's 750 per tenant! The infrastructure looks like: azbridge 2 vCPU/4GB RAM --->>> Service Bus --->>> WebServer. The test was conducted with 50 users on each of the 10 instances, totaling 500 users continuously browsing the site. In this configuration, for additional security, it is highly recommended to add Azure Frontdoor or Azure App Gateway.

![ContainerAppsAzbridgeOnly](media/ContainerAppsAzbridgeOnly.png)