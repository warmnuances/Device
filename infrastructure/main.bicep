param location string = resourceGroup().location
param organization string = 'vnext-device'

// Functions
module functions 'module/functions.bicep' = {
  name: 'fn-${organization}'
  params: {
    appInsightsLocation: location
    location: location
    appName: 'fn-app-${organization}'
  }
}

// Service Bus


output results object = {
  rgId: resourceGroup().id
}
