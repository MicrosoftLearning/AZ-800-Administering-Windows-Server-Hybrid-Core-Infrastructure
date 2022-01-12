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

# Enable PowerShell Remoting on the VM.
Write-Host "Enabling PowerShell Remoting on virtual machine $Name" -ForegroundColor Green
Enable-AzVMPSRemoting -Name $Name -ResourceGroupName $ResourceGroupName

# Determine the certificate to be used for MSI installation.
$checkCertOnVMLiteral =
@'
Get-ChildItem "Cert:\LocalMachine\My" | Where-Object {$_.Thumbprint -eq "<certThumbprint>"}
'@
if ($GenerateSslCert) {
    Write-Host "The MSI will generate the self-signed certificate." -ForegroundColor Green
} else {
    # Check if the key vault certificate is already installed on the VM.
    $cert = Get-AzureKeyVaultCertificate -VaultName $VaultName -Name $CertName
    if (-not $cert) {
        Write-Error "We couldn't find certificate $CertName in key vault $VaultName"
        return
    }
    $certThumbprint = $cert.Thumbprint

    $checkCertOnVMLiteral = $checkCertOnVMLiteral.Replace('<certThumbprint>', $certThumbprint)
    $checkCertOnVMScriptBlock = [ScriptBlock]::Create($checkCertOnVMLiteral)
    $hasCert = Invoke-AzVMCommand -ResourceGroupName $ResourceGroupName -Name $Name -ScriptBlock $checkCertOnVMScriptBlock -Credential $Credential

    if ($hasCert) {
        Write-Host "The MSI will use the installed certificate $CertName in key vault $VaultName" -ForegroundColor Green
    } else {
        Write-Host "Adding the given certificate $CertName from key vault $VaultName to virtual machine $Name" -ForegroundColor Green
        Write-Host "After the certificate is added to the virtual machine, it will be used for the MSI installation" -ForegroundColor Green

        $certURL = (Get-AzureKeyVaultSecret -VaultName $VaultName -Name $CertName).id
        $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $Name
        $sourceVaultId = (Get-AzKeyVault -VaultName $VaultName).ResourceId
        $vm = Add-AzVMSecret -VM $vm -SourceVaultId $sourceVaultId -CertificateStore "My" -CertificateUrl $certURL
        $result = Update-AzVM -ResourceGroupName $ResourceGroupName -VM $vm

        if (-not $result.IsSuccessStatusCode) {
            Write-Error "We couldn't add the given certificate to virtual machine $Name."
            return
        }
    }
}

# Determine the MSI path to be used for installation. If no MSI path is given, then download the MSI.
# Afterwards, register and start the scheduled task to run the MSI installation.
# Script literal for MSI installation.
$msiScriptLiteral =
@'
if (<MsiPathFlag>) {
    Write-Host "Starting Windows Admin Center MSI installation using MSI from '<MsiPath>'" -ForegroundColor Green
    $executePath = "<MsiPath>"
} else {
    $executePath = "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"
    $wacDownload = "https://aka.ms/WACDownload"
    
    Write-Host "Downloading Windows Admin Center MSI on virtual machine <Name> from $wacDownload" -ForegroundColor Green
    Write-Host "The MSI filepath will be '$executePath'"
    Invoke-WebRequest -UseBasicParsing -Uri $wacDownload -OutFile $executePath
    
    Write-Host "Starting Windows Admin Center MSI installation" -ForegroundColor Green
}

# Start scheduled task process to begin MSI installation.
$taskPath = "\Microsoft\WindowsAdminCenter"
$wacProductName = "Windows Admin Center"

Write-Host "Unregistering scheduled task '<taskName>' if it already exists"
Get-ScheduledTask | ? TaskName -eq "<taskName>" | Unregister-ScheduledTask -Confirm:$false

$timestamp = Get-Date -Format yyMM-dd-HHmm
if (<GenerateSslCert>) {
    $argumentString = "/qn /l*v WAC_MSIlog_$timestamp.txt SME_PORT=<PortNumber> SSL_CERTIFICATE_OPTION=generate"
} else {
    $argumentString = "/qn /l*v WAC_MSIlog_$timestamp.txt SME_PORT=<PortNumber> SSL_CERTIFICATE_OPTION=installed SME_THUMBPRINT=<certThumbprint>"
}
$action = New-ScheduledTaskAction -Execute $executePath -Argument $argumentString

Write-Host "Registering scheduled task '<taskName>'"
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType S4U
$task = Register-ScheduledTask -TaskName "<taskName>" -TaskPath $taskPath -Action $action -Principal $principal -Force

Write-Host "Starting scheduled task '<taskName>'"
$null = Start-ScheduledTask -InputObject $task

$secondsToStart = 10
$endTime = [DateTime]::Now.AddSeconds($secondsToStart)
$taskHasStarted = $false

while ([DateTime]::Now -lt $endTime) {
    $taskInfo = Get-ScheduledTask | ?  TaskName -eq "<taskName>" | Get-ScheduledTaskInfo
    if ($taskInfo.LastRunTime) {
        Write-Host "Scheduled task '<taskName>' has started execution"
        $taskHasStarted = $true
        break
    }
}
if (-not $taskHasStarted) {
    Write-Error "Scheduled task '<taskName>' failed to start in $secondsToStart seconds."
}

return $taskHasStarted
'@
# Assign the script literal parameters for the MSI installation.
$msiScriptLiteral = $msiScriptLiteral.Replace('<taskName>', $taskName)
$msiScriptLiteral = $msiScriptLiteral.Replace('<Name>', $Name)
$msiScriptLiteral = $msiScriptLiteral.Replace('<PortNumber>', $PortNumber)
if ($GenerateSslCert) {
    $msiScriptLiteral = $msiScriptLiteral.Replace('<GenerateSslCert>', '$True')
} else {
    $msiScriptLiteral = $msiScriptLiteral.Replace('<GenerateSslCert>', '$False')
    $msiScriptLiteral = $msiScriptLiteral.Replace('<certThumbprint>', $certThumbprint)
}
if ($MsiPath) {
    $msiScriptLiteral = $msiScriptLiteral.Replace('<MsiPathFlag>', '$True')
    $msiScriptLiteral = $msiScriptLiteral.Replace('<MsiPath>', $MsiPath)
} else {
    $msiScriptLiteral = $msiScriptLiteral.Replace('<MsiPathFlag>', '$False')
    $msiScriptLiteral = $msiScriptLiteral.Replace('<MsiPath>', '$False')
}
# Convert the script literal to ScriptBlock, then invoke it.
$msiScriptBlock = [ScriptBlock]::Create($msiScriptLiteral)
$taskHasStarted = Invoke-AzVMCommand -ResourceGroupName $ResourceGroupName -Name $Name -ScriptBlock $msiScriptBlock -Credential $Credential

# If the scheduled task failed to start, then end the installation process.
if (-not $taskHasStarted) {
    Write-Error "Ending installation of WAC on virtual machine $Name."
    return
}

# Poll the MSI installation to determine result, retry the installation if it fails.
$getTaskInfoScriptLiteral = 
@'
Get-ScheduledTask | ? TaskName -eq "<taskName>" | Get-ScheduledTaskInfo
'@
$getTaskInfoScriptLiteral = $getTaskInfoScriptLiteral.Replace('<taskName>', $taskName)
$getTaskInfoScriptBlock = [ScriptBlock]::Create($getTaskInfoScriptLiteral)

$startScheduledTaskScriptLiteral = 
@'
$task = Get-ScheduledTask | ? TaskName -eq "<taskName>"

Write-Host "Starting scheduled task '<taskName>'"
$null = Start-ScheduledTask -InputObject $task
'@
$startScheduledTaskScriptLiteral = $startScheduledTaskScriptLiteral.Replace('<taskName>', $taskName)
$startScheduledTaskScriptBlock = [ScriptBlock]::Create($startScheduledTaskScriptLiteral)

$count = 0
$retryAttempts = 3
$continueRetry = $true

while ($count -le $retryAttempts) {
    $minutesToInstall = 10
    $endTime = [DateTime]::Now.AddMinutes($minutesToInstall)
    $taskComplete = $null

    while ([DateTime]::Now -lt $endTime) {
        try {
            $taskInfo = Invoke-AzVMCommand -ResourceGroupName $ResourceGroupName -Name $Name -ScriptBlock $getTaskInfoScriptBlock -Credential $Credential
            Write-Host "'$taskName' scheduled task last run at $([DateTime]::Now.ToString('HH:mm:ss')) has a last task result of $($taskInfo.LastTaskResult)"
            if ($taskInfo.LastTaskResult -eq 0) {
                $taskComplete = $true
            }
        } catch {
            # ignore exception
        }

        if ($taskComplete) {
            break
        }
        if ($taskInfo.LastTaskResult -eq 1603) {
            Write-Warning "MSI installation failed with the code 'Fatal Error During Installation' (1603)."
            break
        }
        if ($taskInfo.LastTaskResult -eq 1618) {
            Write-Warning "MSI installation failed with the code 'ERROR_INSTALL_ALREADY_RUNNING' (1618)."
            break
        }
        if ($taskInfo.LastTaskResult -eq 1619) {
            # The given MSI filepath could not be opened. Do not retry MSI installation.
            Write-Error "MSI installation failed with the code 'ERROR_INSTALL_PACKAGE_OPEN_FAILED' (1619)."
            $continueRetry = $false
            break
        }
        if ($taskInfo.LastTaskResult -eq 1620) {
            # The given MSI filepath could not be opened. Do not retry MSI installation.
            Write-Error "MSI installation failed with the code 'ERROR_INSTALL_PACKAGE_INVALID' (1620)."
            $continueRetry = $false
            break
        }
        if ($taskInfo.LastTaskResult -eq 1641) {
            Write-Warning "You must restart your system for the configuration changes made to Windows Admin Center to take effect."
            $taskComplete = $true
            break
        }

        Start-Sleep -Seconds 10
    }

    if (-not $taskComplete -and $continueRetry) {
        Write-Host "Retrying MSI installation, attempt $($count + 1) of $retryAttempts" -ForegroundColor Green
        Invoke-AzVMCommand -ResourceGroupName $ResourceGroupName -Name $Name -ScriptBlock $startScheduledTaskScriptBlock -Credential $Credential
        $count++
    } else {
        break
    }
}

if (-not $taskComplete) {
    Write-Error "We couldn't install Windows Admin Center MSI on virtual machine $Name."
    return
}

Write-Host "Installation of Windows Admin Center on virtual machine $Name is successful" -ForegroundColor Green

# Verify that the firewall rule was created.
Write-Host "Verifying that the firewall rule for inbound traffic was created" -ForegroundColor Green
$checkFirewallScriptBlock = {
    if (-not (Get-NetFirewallRule | ? DisplayName -eq SmeInboundOpenException)) {
	    $null = New-NetFirewallRule -DisplayName SmeInboundOpenException -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow -Description "Windows Admin Center inbound port exception"
	}
}
Invoke-AzVMCommand -ResourceGroupName $ResourceGroupName -Name $Name -ScriptBlock $checkFirewallScriptBlock -Credential $Credential

# Start Windows Admin Center.
Write-Host "Starting Windows Admin Center" -ForegroundColor Green
Invoke-AzVMCommand -ResourceGroupName $ResourceGroupName -Name $Name -ScriptBlock {Start-Service ServerManagementGateway} -Credential $Credential

# Return the public IP and FQDN (if available) of the VM so that the user can access WAC.
$vm = Get-AzureRmVM -ResourceGroupName $ResourceGroupName -Name $Name
$nicId = $vm.NetworkProfile.NetworkInterfaces[0].Id -replace '.*\/'
$nic = Get-AzureRmNetworkInterface -Name $nicId -ResourceGroupName $ResourceGroupName
$nicIpConfig = Get-AzureRmNetworkInterfaceIpConfig -NetworkInterface $nic
$publicIpId = $nicIpConfig.PublicIpAddress.Id -replace '.*\/'
$publicIp = Get-AzureRmPublicIpAddress -Name $publicIpId -ResourceGroupName $ResourceGroupName
$publicIpAddress =  $publicIp.IpAddress
if ($publicIpAddress -eq "Not Assigned") {
    $publicIpAddress = $null
}
if ($publicIp.DnsSettings) {
    $fqdn = $publicIp.DnsSettings.Fqdn
}

if ($fqdn -and $publicIpAddress) {
    Write-Host "Windows Admin Center was successfully started. Please access WAC by visiting https://$publicIpAddress or https://$fqdn" -ForegroundColor Green
} elseif ($publicIpAddress) {
    Write-Host "Windows Admin Center was successfully started. Please access WAC by visiting https://$publicIpAddress" -ForegroundColor Green
} else {
    Write-Host "We couldn't get the public IP or FQDN of virtual machine $Name. Please first configure these settings, then access WAC by visiting https://<Public IP of VM> or https://<FQDN of VM>" -ForegroundColor Green
}

# If the pre-existing VM does not have port 443 open, then write a message alerting the user of this issue when using WAC.
if ($InstallWACOnly) {
    $nsg = Get-AzureRmEffectiveNetworkSecurityGroup -NetworkInterfaceName $nicId -ResourceGroupName $ResourceGroupName
    $nsgId = $nsg.NetworkSecurityGroup.Id -replace '.*\/'
    $hasSSLPort = $nsg.EffectiveSecurityRules | Where-Object {$_.DestinationPortRange -eq "443-443"}
    if (-not $hasSSLPort) {
        Write-Host "Please note that port 443 must be an inbound security rule in the associated network security group $nsgId for virtual machine $Name to access WAC in service mode."
    }
}
