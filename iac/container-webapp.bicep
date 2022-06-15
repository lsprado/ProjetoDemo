// az deployment group create --resource-group $rgName --template-file .\container-webapp.bicep --parameters webApiName='capp-myprojectdemo-api' webAppName='capp-myprojectdemo-app' servicePlan='asp-myprojectdemocontainer' skuName='S1' acrName='acrprojetodemo' dockerUsername='acrprojetodemo' dockerImageAndTagApi='projetodemo.webapi:latest' dockerImageAndTagApp='projetodemo.webapp:latest'
// az webapp config appsettings set --resource-group $rgName --name capp-myprojectdemo-app --settings Services__Url="https://capp-myprojectdemo-api.azurewebsites.net"

@description('Web app name')
@minLength(3)
param webAppName string

@description('Web api name')
@minLength(3)
param webApiName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Service Plan name')
@minLength(3)
param servicePlan string

@description('The SKU of App Service Plan.')
param skuName string = 'F1'

@description('The ACR name.')
param acrName string

@description('ACR Username to authenticate')
param dockerUsername string

@description('App Image to deployment Ex:projetodemo.webapp:latest')
param dockerImageAndTagApp string

@description('Api Image to deployment Ex:projetodemo.webapi:latest')
param dockerImageAndTagApi string

param acrResourceGroup string = resourceGroup().name
param acrSubscription string = subscription().subscriptionId

var appServicePlanName = toLower(servicePlan)
var appName = toLower(webAppName)
var apiName = toLower(webApiName)

// external ACR info
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' existing = {
  scope: resourceGroup(acrSubscription, acrResourceGroup)
  name: acrName
}

resource siteApp 'microsoft.web/sites@2020-06-01' = {
  name: appName
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrName}.azurecr.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'Services__Url' // other option is Services:Url
          value: 'https://${siteApi.properties.defaultHostName}'
        }
      ]
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${dockerImageAndTagApp}'
    }
    serverFarmId: appServicePlan.id
  }
}

resource siteApi 'microsoft.web/sites@2020-06-01' = {
  name: apiName
  location: location
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${acrName}.azurecr.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: containerRegistry.listCredentials().passwords[0].value
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      linuxFxVersion: 'DOCKER|${acrName}.azurecr.io/${dockerImageAndTagApi}'
    }
    serverFarmId: appServicePlan.id
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
  }
  kind: 'linux'
  properties: {
    targetWorkerSizeId: 0
    targetWorkerCount: 1
    reserved: true
  }
}

output publicUrlApi string = siteApi.properties.defaultHostName
output publicUrlApp string = siteApp.properties.defaultHostName
