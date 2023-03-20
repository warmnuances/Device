param location string = resourceGroup().location
param organization string = 'vnext-device'

@description('Provide the administrator login password for the MySQL server.')
@secure()
param administratorLoginPassword string


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

//Db mysql
module mysql 'module/mysql.bicep' = {
  name: 'resource-azure-db-mysql-${organization}'
  params: {
    resourceNamePrefix: organization
    location: location
    administratorLogin: 'vnext-root'
    administratorLoginPassword: administratorLoginPassword
  }
}


output results object = {
  rgId: resourceGroup().id
}
