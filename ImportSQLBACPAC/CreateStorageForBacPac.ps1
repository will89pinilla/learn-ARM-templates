$projectName = Read-Host -Prompt "Enter a project name that is used to generate Azure resource names"
$location = Read-Host -Prompt "Enter the location (i.e. centralus)"

$resourceGroupName = "${projectName}rg"
$storageAccountName = "${projectName}store"
$containerName = "bacpacfiles"
$bacpacFileName = "SQLDatabaseExtension.bacpac"
$bacpacUrl = "https://github.com/Azure/azure-docs-json-samples/raw/master/tutorial-sql-extension/SQLDatabaseExtension.bacpac"

# Download the bacpac file
Invoke-WebRequest -Uri $bacpacUrl -OutFile "$HOME/$bacpacFileName"

# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName `
                                       -Name $storageAccountName `
                                       -SkuName Standard_LRS `
                                       -Location $location
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName `
                                              -Name $storageAccountName).Value[0]

# Create a container
New-AzStorageContainer -Name $containerName -Context $storageAccount.Context

# Upload the BACPAC file to the container
Set-AzStorageBlobContent -File $HOME/$bacpacFileName `
                         -Container $containerName `
                         -Blob $bacpacFileName `
                         -Context $storageAccount.Context

Write-Host "The storage account key is $storageAccountKey"
Write-Host "The BACPAC file URL is https://$storageAccountName.blob.core.windows.net/$containerName/$bacpacFileName"
Write-Host "Press [ENTER] to continue ..."
