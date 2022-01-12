Invoke-Command -ComputerName 'SEA-SVR1.contoso.com' -ScriptBlock {
   Get-Disk
   Initialize-Disk -Number 1
   New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter S
   Format-Volume -DriveLetter S -FileSystem NTFS
}

Invoke-Command -ComputerName 'SEA-SVR2.contoso.com' -ScriptBlock {
   Get-Disk
   Initialize-Disk -Number 1
   New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter S
   Format-Volume -DriveLetter S -FileSystem NTFS
}

New-Item -Type Directory -Path '\\SEA-SVR1.contoso.com\S$\Root'
New-Item -Type Directory -Path '\\SEA-SVR1.contoso.com\S$\Data'
New-Item -Type Directory -Path '\\SEA-SVR2.contoso.com\S$\Data'

Invoke-Command -ComputerName 'SEA-SVR1.contoso.com' -ScriptBlock {
	New-SmbShare -Name Root -Path 'S:\Root' -ChangeAccess 'Users' -FullAccess 'Administrators'
	New-SmbShare -Name Data -Path 'S:\Data' -ChangeAccess 'Users' -FullAccess 'Administrators'
	Install-WindowsFeature -Name FS-DFS-Namespace -IncludeManagementTools -IncludeAllSubFeature
	Install-WindowsFeature -Name FS-DFS-Replication -IncludeManagementTools -IncludeAllSubFeature
}

Invoke-Command -ComputerName 'SEA-SVR2.contoso.com' -ScriptBlock {
	New-SmbShare -Name Data -Path 'S:\Data' -ChangeAccess 'Users' -FullAccess 'Administrators'
	Install-WindowsFeature -Name FS-DFS-Namespace -IncludeManagementTools -IncludeAllSubFeature
	Install-WindowsFeature -Name FS-DFS-Replication -IncludeManagementTools -IncludeAllSubFeature
}

New-DfsnRoot -TargetPath '\\SEA-SVR1.contoso.com\Root' -Type DomainV2 -Path '\\Contoso.com\Root'
New-DfsnFolder -Path '\\Contoso.com\Root\Data' -TargetPath '\\SEA-SVR1.Contoso.com\Data' -Description 'Data folder'
New-DfsnFolderTarget -Path '\\Contoso.com\Root\Data' -TargetPath '\\SEA-SVR2.Contoso.com\Data'
New-DfsReplicationGroup -GroupName 'Branch1' | New-DfsReplicatedFolder -FolderName 'Data' | Add-DfsrMember -ComputerName 'SEA-SVR1','SEA-SVR2'

Add-DfsrConnection -GroupName 'Branch1' -SourceComputerName 'SEA-SVR1' -DestinationComputerName 'SEA-SVR2'
Set-DfsrMembership -GroupName 'Branch1' -FolderName 'Data' -ContentPath 'S:\Data' -ComputerName 'SEA-SVR1' -PrimaryMember $True -Force
Set-DfsrMembership -GroupName 'Branch1' -FolderName 'Data' -ContentPath 'S:\Data' -ComputerName 'SEA-SVR2' -Force