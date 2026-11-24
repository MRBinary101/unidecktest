@description('Azure region for the virtual networks and NSGs')
param location string

@description('Allowed source IP or CIDR for RDP access (defaults to Internet/Any, restrict to your IP in production)')
param allowedRdpSource string = '*'

// Reusable list of inbound security rules
var defaultSecurityRules = [
  {
    name: 'Allow-HTTPS-Inbound'
    properties: {
      description: 'Allow inbound HTTPS traffic'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
  {
    name: 'Allow-RDP-Inbound'
    properties: {
      description: 'Allow inbound RDP traffic'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3389'
      sourceAddressPrefix: allowedRdpSource
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 110
      direction: 'Inbound'
    }
  }
]

// 1. Network Security Groups
resource nsg1 'Microsoft.Network/networkSecurityGroups@2025-01-01' = {
  name: 'nsg-hub-default'
  location: location
  properties: {
    securityRules: defaultSecurityRules
  }
}

resource nsg2 'Microsoft.Network/networkSecurityGroups@2025-01-01' = {
  name: 'nsg-spoke-default'
  location: location
  properties: {
    securityRules: defaultSecurityRules
  }
}

// 2. Virtual Networks with NSGs attached to subnets
resource vnet1 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: 'vnet-hub-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: nsg1.id
          }
        }
      }
    ]
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2025-01-01' = {
  name: 'vnet-spoke-01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-default'
        properties: {
          addressPrefix: '10.1.0.0/24'
          networkSecurityGroup: {
            id: nsg2.id
          }
        }
      }
    ]
  }
}

// 3. Bidirectional VNet Peering
resource peering1To2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-01-01' = {
  parent: vnet1
  name: 'peer-hub-to-spoke'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet2.id
    }
  }
}

resource peering2To1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2025-01-01' = {
  parent: vnet2
  name: 'peer-spoke-to-hub'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet1.id
    }
  }
}

output vnet1Id string = vnet1.id
output vnet2Id string = vnet2.id
