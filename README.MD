# Azure Hybrid Application Proxy - Scalable reverse proxy solution with flexible identity provider support

The Azure Hybrid Application Proxy project aims to create a highly scalable and flexible reverse proxy solution built on Azure App Service and leveraging Azure App Service Hybrid Connections. The key objectives are:

1. **Massive Scale**: Overcome the 750 requests per second limit of the current Azure Application Proxy offering to enable massive scale.

2. **Flexible Identity Provider Support**: Extend identity provider support beyond Azure Active Directory to also integrate with Azure AD B2C and potentially other IDPs in the future. This will allow applications to authenticate users from various identity sources.

3. **Azure App Service Foundation**: Utilize Azure App Service as the core hosting platform to gain benefits such as auto-scaling, high availability, and managed runtimes.

4. **Secure Hybrid Connectivity**: Implement Azure App Service Hybrid Connections to securely connect the proxy to on-premises web applications without requiring opening inbound ports on the firewall.

5. **Pure Reverse Proxy**: Act as a pure reverse proxy solution, securely relaying authenticated requests to backend applications. The proxy itself will not implement any application logic.

6. **NGINX-based Ingress Controller**: Utilize the well-known Ingress Controller based on NGINX to handle incoming traffic, load balancing, and routing requests to the appropriate backend services.

The solution uses nginx-container-proxy: https://github.com/MariuszFerdyn/nginx-container-proxy. 
Always ensure you are using the latest container build available here: https://hub.docker.com/r/mafamafa/nginx-container-proxy.

You can deploy the solution using [AppService](AppService.md) or with [Container Apps](ContainerApp.MD). Container Apps give you a performance boost.

You can see the performance results here - [Performance.md](Performance.md).