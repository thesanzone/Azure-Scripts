

$storageAccounts = Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' 

foreach ($storageAccount in $storageAccounts) {
	$sgname = $storageAccount.Name
	if ($sgname.StartsWith("free")) {
		write-host "name: "  $storageAccount.Name "rg:  " $storageAccount.ResourceGroupName 
		Remove-AzStorageAccount -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.Name -force
	}	
}	
