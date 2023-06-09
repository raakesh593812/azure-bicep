@description('Location for all resources.')
param region string 
var publicIPAddressName = 'public_ip_agw'
param virtualNetworkName string
param virtualNetworkNameRG string
param subnetname string
var applicationGateWayName = 'myAppGwpocsamix1'
param bep array
param feports array
param behttpsettings array

resource resvirtualNetwork 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
   name: virtualNetworkName
   scope: resourceGroup(virtualNetworkNameRG)

     resource rsubnet 'subnets@2022-07-01' existing = {
     name: subnetname
  }
}


resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = [for i in range(0, 1): {
  name: '${publicIPAddressName}${i}'
  location: region
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}]



resource applicationGateWay 'Microsoft.Network/applicationGateways@2021-05-01' = {
  name: applicationGateWayName
  location: region
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resvirtualNetwork::rsubnet.id
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${publicIPAddressName}0')
          }
        }
      }
    ]
    frontendPorts: [ for feport in feports : {
        name: feport.name
        properties: {
          port: feport.port
        }
      }]
    backendAddressPools: [for bpool in bep: {
        name: bpool.name
        properties: {}
      }]
      
backendHttpSettingsCollection: [ for behttpsetting in behttpsettings: {
        name: behttpsetting.name
        properties: {
          port: behttpsetting.port
          protocol: behttpsetting.protocol
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }]
    httpListeners: [
      {
        name: 'myListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateWayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateWayName, 'port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'myRoutingRule'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateWayName, 'myListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateWayName, 'myBackendPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateWayName, 'myHTTPSetting')
          }
        }
      }
    ]
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
  }
  dependsOn: [
    publicIPAddress
  ]
}
