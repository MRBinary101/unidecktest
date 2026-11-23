# Create Resource Group
New-AzResourceGroup `
    -Name "myResourceGroup" `
    -Location "UKSouth"

# Create subnet configuration
$subnet = New-AzVirtualNetworkSubnetConfig `
    -Name "mySubnet" `
    -AddressPrefix "10.10.1.0/24"

# Create VNet
$vnet = New-AzVirtualNetwork `
    -ResourceGroupName "myResourceGroup" `
    -Location "UKSouth" `
    -Name "myVnet" `
    -AddressPrefix "10.10.0.0/16" `
    -Subnet $subnet

# VM credentials
$username = "azureadmin"
$password = ConvertTo-SecureString "P@ssw0rd123456!" -AsPlainText -Force

$cred = New-Object System.Management.Automation.PSCredential (
    $username,
    $password
)

# Create VM
New-AzVm `
    -ResourceGroupName "myResourceGroup" `
    -Name "myVM" `
    -Location "UKSouth" `
    -Size "Standard_B2ms" `
    -Image "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest" `
    -VirtualNetworkName "myVnet" `
    -SubnetName "mySubnet" `
    -SecurityGroupName "myNetworkSecurityGroup" `
    -PublicIpAddressName "myPublicIpAddress" `
    -Credential $cred `
    -OpenPorts 80,3389