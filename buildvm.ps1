#syntax
#  .ps1 -name VMNAME -rg VMRGNAME -sn SubnetName
# gets the sshkey from the resource group name right now for Finance and Operations


#Input Parameters
param ([Parameter(Mandatory)]$name, [Parameter(Mandatory)]$rg, [Parameter(Mandatory)]$subnet)

#Basic VM Settings
#    $vmResourceGroupName = "Finance_RG";
#    $vmName = "finance02";

$vmResourceGroupName = $rg;
$vmName = $name;
$vmLocation = "East US";
$vmSize = "Standard_B1s";

#Setting Credentials
$VMLocalAdminUser = "azureuser";
$VMLocalAdminSecurePassword = ConvertTo-SecureString "P@ssword123!" -AsPlainText -Force;
$Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser,$VMLocalAdminSecurePassword);
$sshKeyName = $vmResourceGroupName + "_key"


#Virtual Networking Variables
$vnetResourceGroupName = "AZ-104-DEFAULT-RG";
$vnetName = "AZ-104-DEFAULT-VNET-EASTUS";
# $subnetName = "AZ-104-FINANCE-SUBNET";
$subnetName = $subnet

# Image Info...
$imagePublisher = "Canonical";
$imageOffer = "0001-com-ubuntu-server-jammy";
$imageSku = "22_04-lts-gen2";
$imageVersion = "latest";

write-host $vmName ":  Setting Network Config..."
# Get the virtual network and subnet
$vnet = Get-AzVirtualNetwork -ResourceGroupName $vnetResourceGroupName -Name $vnetName;
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName;
$vmNic = New-AzNetworkInterface -Name $vmName -ResourceGroupName $vmResourceGroupName -Location $vmLocation -SubnetId $subnet.Id -force


write-host $vmName ":  Setting VM Configuration..."
# Create a new VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize 
$vmConfig = Set-AzVMOSDisk -VM $vmConfig -StorageAccountType "StandardSSD_LRS" -DeleteOption Delete -CreateOption FromImage;
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential $Credential;
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version $imageVersion;




$vmConfig = Set-AzVMBootDiagnostic -VM $vmConfig -disable;
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id $vmNic.Id -DeleteOption Delete;

""
"======================"
"Building New VM..."
"Resource Group : " + $vmResourceGroupName
"VM Name        : " + $vmName
"sshKeyName     : " + $sshKeyName
""
"======================"
""

# Create the VM
New-AzVM `
	-ResourceGroupName $vmResourceGroupName `
	-Location $vmLocation `
	-VM $vmConfig  `
	-SshKeyName $sshKeyName `
	-Verbose
	
#end of script
