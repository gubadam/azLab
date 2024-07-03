targetScope = 'subscription'

param appName string = 'poc'

param location string = deployment().location

@allowed([
  'dev'
  'test'
  'prod'
])
param env string = 'dev'

module rg 'br/public:avm/res/resources/resource-group:0.2.4' = {
  name: '${uniqueString(deployment().name)}-resourceGroup'
  scope: subscription()
  params: {
    name: 'rg-${env}-${appName}'
    location: location
  }
}

output rgName string = rg.outputs.name
output rgId string = rg.outputs.resourceId
output rgLocation string = rg.outputs.location
