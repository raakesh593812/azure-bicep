targetScope = 'subscription'

@description('Deployment region.')
param region string = 'eastus2'

@description('Deployment environment name')
@allowed([
  'dev'
  'uat'
  'perf'
  'prod'
])
param environmentName string
@description('Deployment rg prefix')
param rgnames array 
//var networkResourceGroupName = '${environmentName}-${appPrefix}-network-rg-${region}-01'
//var isProd = (environmentName == 'prod')


var rgname_full = [for rgname in rgnames: {
  name: '${environmentName}-${rgname}-network-rg-${region}-01'
  location: region 
} ]

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = [for rg in rgname_full: {
  name: rg.name
 location: rg.location
}]


// Outputs
output rg_op array = [for (name, i) in rgname_full: {
  rgName: rg[i].name
  Location: rg[i].location
  resource_id: rg[i].id
}]
