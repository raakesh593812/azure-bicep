targetScope = 'subscription'
param rgnames array 
param vnetName string 
param vnetRG string 
param vnet_subnetname string 
param parbep array
param parfeports array
param parbehttpsettings array
module modrg 'modules/ResourceGroup.bicep' = {
  name: 'ResourceGroup'
  params: {
    region: 'westeurope'
    environmentName: 'dev'
    rgnames: [
            'contoso'
            'fabrikam'
            'coho'
              ]
  }
}

module modpublicip 'modules/appgw.bicep' = {
name: 'publicip'
scope: resourceGroup('dev-fabrikam-network-rg-westus2-01')
params: {
 region: 'westeurope'
 virtualNetworkName : vnetName
 virtualNetworkNameRG:  vnetRG
 subnetname : vnet_subnetname
 bep :  parbep
feports : parfeports 
behttpsettings : parbehttpsettings

}
dependsOn: [
    modrg
  ]
}

output modrgname array  = modrg.outputs.rg_op

//output resourcename string  = filter(modrg.outputs.rg_op, s => s.rgName == 'dev-fabrikam-network-rg-westus2-01')[0].rgName
