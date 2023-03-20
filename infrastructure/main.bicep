param location string = resourceGroup().location
param organization string = 'vnext-device'

// Functions
module functions 'module/functions.bicep' = {
  name: 'resource-fn-${organization}'
  params: {
    appInsightsLocation: location
    location: location
    appName: 'fn-app-${organization}'
  }
}

// Logic Apps
module logicapps 'module/logicapp.bicep' = {
  name: 'resource-logicapps-${organization}'
  params: {
    logicAppName: 'logicapps-${organization}'
    location: location
  }
}


output results object = {
  rgId: resourceGroup().id
}
