param location string = resourceGroup().location
param organization string = 'vnext-device'

// Functions
module dbvnetMod 'module/functions.bicep' = {
  name: 'dbvnetMod'
  params: {
    appInsightsLocation: location
    location: location
    appName: 'device'
  }
}

// Service Bus

output results object = {
  rgId: resourceGroup().id
}
