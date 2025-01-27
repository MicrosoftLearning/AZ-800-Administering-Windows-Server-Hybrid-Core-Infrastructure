<#########################################################################################################
 # File: Deploy-WACAzVM.ps1
 #
 # .DESCRIPTION
 #
 #  Install Windows Admin Center on an Azure VM.
 #
 #  Copyright (c) Microsoft Corp 2017.
 #
 #########################################################################################################>

 <#

.SYNOPSIS
Install Windows Admin Center on an Azure VM.

.DESCRIPTION
The Deploy-WACAzVM.ps1 script installs WAC on either a newly created or pre-existing Azure VM.

.PARAMETER ResourceGroupName
Specifies the name of the resource group.

.PARAMETER Name
Specifices the name of the VM.

.PARAMETER Credential
Specifies the credential for the VM.

.PARAMETER MsiPath
Specifies the path of the Windows Admin Center MSI.

.PARAMETER VaultName
Specifies the name of the key vault that contains the certificate.

.PARAMETER CertName
Specifies the name of the certificate to be used for MSI installation.

.PARAMETER GenerateSslCert
True if the MSI should generate a self signed ssl certificate.

.PARAMETER PortNumber
Specifies the ssl port number.

.PARAMETER OpenPorts
Specifies the open ports for the VM.

.PARAMETER Location
Specifies the location of the VM.

.PARAMETER Size
Specifies the size of the VM.

.PARAMETER Image
Specifies the image of the VM.

.PARAMETER VirtualNetworkName
Specifies the name of the virtual network for the VM.

.PARAMETER SubnetName
Specifies the name of the subnet for the VM.

.PARAMETER SecurityGroupName
Specifies the name of the security group for the VM.

.PARAMETER PublicIpAddressName
Specifies the name of the public IP address for the VM.

.PARAMETER InstallWACOnly
True if WAC should be installed on a pre-existing Azure VM.

.EXAMPLE
Install the WAC gateway on a new VM "my-vm" in a new resource group "my-vm".
The MSI is downloaded from aka.ms/WACDownload and it will generate the certificate.

$Credential = Get-Credential
./Deploy-WACAzVM.ps1 -Name "my-vm" -Credential $Credential -GenerateSslCert

.EXAMPLE
Install the WAC gateway on a new VM "my-vm" in a new resource group "my-rg".
The MSI is downloaded from aka.ms/WACDownload and it will use a certificate defined in an Azure Key Vault.

$scriptParams = @{
    ResourceGroupName = "my-rg"
    Name = "my-vm"
    Credential = $Credential
    VaultName = "my-key-vault"
    CertName = "my-cert"
    Location = "eastus"
    Size = "Standard_D4s_v3"
    SubnetName = "my-subnet-name"
    PublicIpAddressName = "my-public-ip-name"
}
./Deploy-WACAzVM.ps1 @scriptParams

.EXAMPLE
Install the WAC gateway on a pre-existing VM "my-vm" in the resource group "my-rg".
The MSI is downloaded from aka.ms/WACDownload and it will generate the certificate.

./Deploy-WACAzVM.ps1 -ResourceGroupName "my-rg" -Name "my-vm" -Credential $Credential -InstallWACOnly -GenerateSslCert

.EXAMPLE
Install the WAC gateway on a pre-existing VM "my-vm" in the resource group "my-rg".
The MSI is found locally on the VM and it will generate the certificate.

$MsiPath = "C:\path\to\WindowsAdminCenter.msi"
./Deploy-WACAzVM.ps1 -ResourceGroupName "my-rg" -Name "my-vm" -Credential $Credential -MsiPath $MsiPath -InstallWACOnly -GenerateSslCert

#>

#Requires -RunAsAdministrator

[CmdletBinding(DefaultParameterSetName='CreateVMGenerateCert')]
param (
    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='InstallWACOnlyGenerateCert', Mandatory=$true)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [Parameter(ParameterSetName='InstallWACOnlySpecifyCert', Mandatory=$true)]
    [String]
    $ResourceGroupName,

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$true)]
    [Parameter(ParameterSetName='InstallWACOnlyGenerateCert', Mandatory=$true)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$true)]
    [Parameter(ParameterSetName='InstallWACOnlySpecifyCert', Mandatory=$true)]
    [String]
    $Name,

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$true)]
    [Parameter(ParameterSetName='InstallWACOnlyGenerateCert', Mandatory=$true)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$true)]
    [Parameter(ParameterSetName='InstallWACOnlySpecifyCert', Mandatory=$true)]
    [PSCredential]
    $Credential,

    [Parameter(ParameterSetName='InstallWACOnlyGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='InstallWACOnlySpecifyCert', Mandatory=$false)]
    [String]
    $MsiPath,

    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$true)]
    [Parameter(ParameterSetName='InstallWACOnlySpecifyCert', Mandatory=$true)]
    [String]
    $VaultName,

    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$true)]
    [Parameter(ParameterSetName='InstallWACOnlySpecifyCert', Mandatory=$true)]
    [String]
    $CertName,

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$true)]
    [Parameter(ParameterSetName='InstallWACOnlyGenerateCert', Mandatory=$true)]
    [ValidateSet($true)]
    [switch]
    $GenerateSslCert,

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [int]
    $PortNumber = 443,

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [int[]]
    $OpenPorts = @(),

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [String]
    $Location,

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [String]
    $Size = "Standard_DS1_v2",

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [String]
    $Image = "Win2019Datacenter",

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [String]
    $VirtualNetworkName,

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [String]
    $SubnetName,

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [String]
    $SecurityGroupName,

    [Parameter(ParameterSetName='CreateVMGenerateCert', Mandatory=$false)]
    [Parameter(ParameterSetName='CreateVMSpecifyCert', Mandatory=$false)]
    [String]
    $PublicIpAddressName,

    [Parameter(ParameterSetName='InstallWACOnlyGenerateCert', Mandatory=$true)]
    [Parameter(ParameterSetName='InstallWACOnlySpecifyCert', Mandatory=$true)]
    [ValidateSet($true)]
    [switch]
    $InstallWACOnly
)

# Define the name of the scheduled task for MSI installation.
$taskName = "Install Windows Admin Center"

# Add the specifed WAC port number to the list of open ports for the VM.
$OpenPorts += $PortNumber

# If the name of the resource group was not provided, then the name of the resource group will be the name of the VM.
if ((-not $InstallWACOnly) -and (-not $ResourceGroupName)) {
    Write-Host "Since a resource group name was not provided, the name of the resource group will be $Name" -ForegroundColor Green
    $ResourceGroupName = $Name
}

# Create a VM if it was not provided.
if (-not $InstallWACOnly) {
    Write-Host "Creating virtual machine $Name in resource group $ResourceGroupName" -ForegroundColor Green
    $vmParameters = @{
        ResourceGroupName = $ResourceGroupName
        Name = $Name
        Credential = $Credential
        OpenPorts = $OpenPorts
        Size = $Size
        Image = $Image
    }
    if ($Location) {
        $vmParameters.Location = $Location
    }
    if ($SubnetName) {
        $vmParameters.SubnetName = $SubnetName
    }
    if ($VirtualNetworkName) {
        $vmParameters.VirtualNetworkName = $VirtualNetworkName
    }
    if ($SecurityGroupName) {
        $vmParameters.SecurityGroupName = $SecurityGroupName
    }
    if ($PublicIpAddressName) {
        $vmParameters.PublicIpAddressName = $PublicIpAddressName
    }
    $result = New-AzureRmVM @vmParameters

    if (-not $result) {
        Write-Error "We couldn't create the virtual machine using the New-AzureRmVM cmdlet."
        return
    }
}