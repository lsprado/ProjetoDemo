// az deployment group create --resource-group $rgName --template-file .\main.bicep --parameters servicePlan='asp-myprojectdemo' skuName='S1' webAppName='capp-MyProjectDemo-app' webApiName='capp-MyProjectDemo-api' acrName='acrprojetodemo' aksClusterName='aksMyProjectDemo' dnsPrefix='aksMyProjectDemo' linuxAdminUsername='leandro' sshRSAPublicKey='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD7N8ZXEi+08cUSEVfxrkUU6jfwSQgcDxGEGdxWAz4hYHkHnv7qC+Xe2mvSitmSxUTXjVBprCGsKxvckAJl1xaeGKf0eC1gX+fVxcaAICy19MHYXE1ChTP+lqzRLeTqEGXLwOxWdrZgQmwITBza/9Yw7MHnc+VFN7xFolp0eG0cZMKMI3JyyJpODBBFZW0MTyMcHMVKzPMOo7Od7EUnK2+o/2bSOUkyc5b2qweKWparoEWUA7w5Zp9fOBL1cr9mRYFBhpnQkvgovbmSGgKn1XuN9DJRwlKDrr9o9SvKjSYIYgPEemMzivKhFUl4Okk3iOxuuQbhXSalFjpy9zvzRMl7 southamerica\\leadro@leadro-2021'

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

@description('The name of the Managed Cluster resource.')
param aksClusterName string

@description('Kubernetes version to use')
param kubernetesVersion string = '1.23.5'

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 2

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_D2_v2'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD7N8ZXEi+08cUSEVfxrkUU6jfwSQgcDxGEGdxWAz4hYHkHnv7qC+Xe2mvSitmSxUTXjVBprCGsKxvckAJl1xaeGKf0eC1gX+fVxcaAICy19MHYXE1ChTP+lqzRLeTqEGXLwOxWdrZgQmwITBza/9Yw7MHnc+VFN7xFolp0eG0cZMKMI3JyyJpODBBFZW0MTyMcHMVKzPMOo7Od7EUnK2+o/2bSOUkyc5b2qweKWparoEWUA7w5Zp9fOBL1cr9mRYFBhpnQkvgovbmSGgKn1XuN9DJRwlKDrr9o9SvKjSYIYgPEemMzivKhFUl4Okk3iOxuuQbhXSalFjpy9zvzRMl7 southamerica\\leadro@leadro-2021'

var appServicePlanName = toLower(servicePlan)
var appName = toLower(webAppName)
var apiName = toLower(webApiName)
var registryName = toLower(acrName)
var aksName = toLower(aksClusterName)

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

// https://codingwithtaz.blog/2021/09/08/azure-pipelines-deploy-aks-with-bicep/
resource aks 'Microsoft.ContainerService/managedClusters@2020-09-01' = {
  name: aksName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    nodeResourceGroup: 'rg-aks-nodes-${aksName}'
    kubernetesVersion: kubernetesVersion
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
output acrLoginServer string = acrResource.properties.loginServer
