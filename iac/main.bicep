@description('Service Plan name')
@minLength(3)
param servicePlan string

@description('The SKU of App Service Plan.')
param skuName string = 'F1'

@description('Web app name')
@minLength(3)
param webAppName string

@description('Web api name')
@minLength(3)
param webApiName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('The Runtime stack')
param linuxFxVersion string = 'DOTNETCORE|6.0'

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

var appServicePlanName = toLower(servicePlan)
var appName = toLower(webAppName)
var apiName = toLower(webApiName)
var registryName = toLower(acrName)

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: appName
  location: location
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource webApi 'Microsoft.Web/sites@2021-02-01' = {
  name: apiName
  location: location
  properties: {
    httpsOnly: true
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource acrResource 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: true
  }
}
