param location string = resourceGroup().location
param organization string = 'vnext-device'

// Functions

// Service Bus

//

output results object = {
  rgId: resourceGroup().id
}
