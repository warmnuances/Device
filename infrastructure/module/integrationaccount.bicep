param name string
param location string = resourceGroup().location

resource integrationaccount 'Microsoft.Logic/integrationAccounts@2016-06-01' = {
  name: name
  location: location
  sku: {
    name: 'Free'
  }
  properties: {
    state: 'Enabled'
  }
}

output id string = integrationaccount.id
