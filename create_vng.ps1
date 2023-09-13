

$rgName = 'AZ-104-DEFAULT-RG'
$location = 'EASTUS'
$vngName = 'AZ-104-VNG-UNIFI'
$RGvnetName = 'AZ-104-DEFAULT-VNET-EASTUS'


$vnet = Get-AZVirtualNetwork -Name $RGvnetName -ResourceGroupName $rgName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name 'gatewaysubnet' -VirtualNetwork $vnet
$publicIP = 'AZ-104-PUBLIC-IP'
$lngName = "AZ-104-LNG-UNIFI"
$SharedKey = "zj2EU7jgPNcw6OaikdQ2BfTEbWl8B/Ek"


#Missing Steps...future...
# Create the LNG
#    Gotta be able to pull the host name of the home lab...not that it changes often...
# How about powershell to modify the remoteIP in the Unifi console?
# Or is there a way to use a DNS entry?  the Unifi console was pretty strict about entering an IP and not an FQDN

# Other Comments...
#  - Tried to create a totally new RG and stuff the LNG, VNG, CONN, and IP into it...but the VNG has to live in the same RG as the VNET

#  Some Code samples along the way...
#  $ngwpip = New-AzPublicIpAddress -Name ngwpip -ResourceGroupName "vnet-gateway" -Location "UK West" -AllocationMethod Dynamic
#  $vnet = New-AzVirtualNetwork -AddressPrefix "10.254.0.0/27" -Location "UK West" -Name vnet-gateway -ResourceGroupName "vnet-gateway" -Subnet $subnet
#  $subnet = Get-AzVirtualNetworkSubnetConfig -name 'gatewaysubnet' -VirtualNetwork $vnet
#  $ngwipconfig = New-AzVirtualNetworkGatewayIpConfig -Name ngwipconfig -SubnetId $subnet.Id -PublicIpAddressId $ngwpip.Id

# Step 1:  Create a new Public IP Address, Basic, with Dynamic Allocation...
Write-Host "Creating the new Public IP Address..."
$ngwpip = New-AzPublicIpAddress -Name $publicIP -ResourceGroupName $rgName -Location $location -Sku Basic -AllocationMethod Dynamic
Write-host "   New IP Address:  " $ngwpip.IpAddress
write-host ""


#$ngwpip = Get-AZPublicIpAddress -Name $publicIP -ResourceGroupName $rgName

#Step 2:  Create the IP Configuration for the New VNG...
$subnet = Get-AzVirtualNetworkSubnetConfig -name 'gatewaysubnet' -VirtualNetwork $vnet
$ngwipconfig = New-AzVirtualNetworkGatewayIpConfig -Name ngwipconfig -SubnetId $subnet.Id -PublicIpAddressId $ngwpip.Id

#Step 3:  Create the new VNG...
write-host "Creating the Virtual Network Gateway..."

New-AzVirtualNetworkGateway -Name $vngName `
	-ResourceGroupName $rgName `
	-Location $location `
	-IpConfigurations $ngwIpConfig  `
	-GatewayType "VPN" `
	-VpnType "RouteBased" `
	-GatewaySku "Basic" `
	-VpnGatewayGeneration "Generation1" `
	-CustomRoute 192.168.1.0/24 `

###
#  Now have to create the connection?

Write-host "Creating the Connection..."

$vng1 = Get-AZVirtualNetworkGateway -ResourceGroupName $rgName -Name $vngName 
$lng1 = Get-AZLocalNetworkGateway -ResourceGroupName $rgName -Name $lngName

New-AzVirtualNetworkGatewayConnection -Name CONN2UNIFI `
	-ResourceGroupName $rgName `
	-Location $location `
	-VirtualNetworkGateway1 $vng1 `
	-LocalNetworkGateway2 $lng1 `
	-ConnectionType IPsec `
	-SharedKey $SharedKey `

#Go back and get the info on the dynmic IP address that should be assigned by now...

$ngwpip = Get-AZPublicIpAddress -Name $publicIP -ResourceGroupName $rgName

Write-host "========================================================="
Write-host "Name of the new Public IP:           " $ngwpip.Name
Write-host "What's the IP that just got created: " $ngwpip.IpAddress
write-host "   - Now Enter the new IP into the Unifi S2S VPN Setting"
Write-host "========================================================="