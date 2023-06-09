targetScope = 'subscription'

@description('Deployment region.')
param region string = 'eastus2'
var virtualNetworkName = 'vnet-shared-hub-westeurope-001'
var vnetrg = 'rg-shared-westeurope-01'
var backendSubnetPrefix = '10.0.1.0/24'
var subnet = subscriptionResourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, 'snet-appgateway')

param sssubnets array = [
  {
    name: 'api'
    subnetPrefix: '10.144.0.0/24'
  }
  {
    name: 'worker'
    subnetPrefix: '10.144.1.0/24'
  }
]


resource resvirtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
   name: virtualNetworkName
   scope: resourceGroup(vnetrg)

     resource rsubnet 'subnets@2022-07-01' existing = {
     name: 'snet-appgateway'
  }
}
resource ressubnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
   parent: resvirtualNetwork 
   name: 'snet-appgateway'
   
}
output op string = resvirtualNetwork.id
output op_subnet string = ressubnet.id

output vnet_subnet string = resvirtualNetwork::rsubnet.id