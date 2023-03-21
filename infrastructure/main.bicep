param location string = resourceGroup().location
param organization string = 'vnext-device'

@description('Provide the administrator login password for the MySQL server.')
@secure()
param administratorLoginPassword string

@description('Provide the connectionString for service bus.')
@secure()
param serviceBusConnectionString string


// Functions
module functions 'module/functions.bicep' = {
  name: 'resource-fn-${organization}'
  params: {
    appInsightsLocation: location
    location: location
    appName: 'fn-app-${organization}'
  }
}

//Db mysql
module mysql 'module/mysql.bicep' = {
  name: 'resource-azure-db-mysql-${organization}'
  params: {
    resourceNamePrefix: organization
    location: location
    administratorLogin: 'vnextroot'
    administratorLoginPassword: administratorLoginPassword
  }
}

module integrationaccount 'module/integrationaccount.bicep' = {
  name: 'resource-integration-account-${organization}'
  params: {
    location: location
    name: 'integration-account-${organization}'
  }
}

module servicebus 'module/servicebus.bicep' = {
  name: 'resource-service-bus-${organization}'
  params: {
    location: location
    serviceBusNamespaceName: 'servicebus-${organization}'
    serviceBusQueueName: 'queue-${organization}'
  }
}


// Logic Apps
module logicapps 'workflows/registerdevice.bicep' = {
  name: 'resource-logicapps-${organization}'
  params: {
    location: location
    serviceBusConnectionId: servicebus.outputs.resource.connectionId
    integrationAccountId: integrationaccount.outputs.id
    serviceBusQueueName: servicebus.outputs.resource.queueName
    functionAppName: functions.outputs.resource.appName
  }
  dependsOn: [
    servicebus
    mysql
    functions
    integrationaccount
  ]
}



output results object = {
  rgId: resourceGroup().id
}
