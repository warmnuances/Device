targetScope = 'subscription'

@allowed([
  'australiaeast'
  'australiasoutheast'
])
param location string = 'australiaeast'
param prefix string = 'default'

module rgModule 'module/rg.bicep' = {
  name: 'rgMod'
  params: {
    name: 'rg-${prefix}'
    location: location
  }
}
