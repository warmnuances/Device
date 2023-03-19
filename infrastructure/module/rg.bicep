

targetScope = 'subscription'

@allowed([
  'australiaeast'
  'australiasoutheast'
])
param location string = 'australiaeast'
param name string = 'default'


resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {  
  name: name
  location: location
}

output resourceGroup object = rg
