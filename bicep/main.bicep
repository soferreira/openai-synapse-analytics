param rgLocation string = resourceGroup().location
param storageNames array = [
  'openaisynapsesample'
]

param containerName string = 'openaisynapsesample'

// Create storages
resource storageAccounts 'Microsoft.Storage/storageAccounts@2021-06-01' = [for name in storageNames: {
  name: '${name}str${uniqueString(resourceGroup().id)}'
  location: rgLocation
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}]

// Create container
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for (name, i) in storageNames: {
  name: '${storageAccounts[i].name}/default/${containerName}'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}]
