targetScope = 'subscription'

@description('Azure region for the resource group and VNets')
param location string = 'eastus'

@description('Name of the resource group to create')
param resourceGroupName string = 'Test-rg'

// 1. Create the Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}

// 2. Deploy the two VNets into the newly created Resource Group
module vnetsModule './vnets.bicep' = {
  name: 'deploy-two-vnets'
  scope: rg
  params: {
    location: location
  }
}
