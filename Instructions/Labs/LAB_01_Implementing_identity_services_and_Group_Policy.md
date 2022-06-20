---
lab:
    title: 'Lab: Implementing identity services and Group Policy'
    module: 'Module 1: Identity services in Windows Server'
---

# Lab: Implementing identity services and Group Policy

## Scenario

You are working as an administrator at Contoso Ltd. The company is expanding its business with several new locations. The Active Directory Domain Services (AD DS) Administration team is currently evaluating methods available in Windows Server for a non-interactive, remote domain controller deployment. The team is also searching for a way to automate certain AD DS administrative tasks. Additionally, the team wants to establish configuration management based on Group Policy Objects (GPO).

## Objectives

After completing this lab, you’ll be able to:

- Deploy a new domain controller on Server Core.
- Configure Group Policy.

## Estimated time: 45 minutes

## Lab setup

Virtual machines: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-ADM1**, and **AZ-800T00A-SEA-SVR1** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-ADM1**, and **AZ-800T00A-SEA-SVR1** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, and **SEA-ADM1**. 

1. Select **SEA-ADM1**.
1. Sign in using the following credentials:

   - Username: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

## Exercise 1: Deploying a new domain controller on Server Core

### Scenario

As a part of business restructuring, Contoso wants to deploy new domain controllers in remote sites with minimal engagement of IT in remote locations. You need to use DC deployment to deploy new domain controllers.

The main tasks for this exercise are as follows:

1. Deploy AD DS on a new Windows Server Core server.
1. Manage AD DS objects with GUI tools and with Windows PowerShell.

#### Task 1: Deploy AD DS on a new Windows Server Core server

1. Switch to **SEA-ADM1** and from **Server Manager**, open Windows PowerShell.
1. Use the **Install-WindowsFeature** cmdlet in Windows PowerShell to install the AD DS role on **SEA-SVR1**.
1. Use the **Get-WindowsFeature** cmdlet to verify the installation.
1. Ensure that you select the **Active Directory Domain Services**, **Remote Server Administration Tools**, and **Role Administration Tools** checkboxes. For the **AD DS** and **AD LDS Tools** nodes, only the **Active Directory module for Windows PowerShell** should be installed, and not the graphical tools, such as the Active Directory Administrative Center.

> **Note**: If you centrally manage your servers, you will not usually need GUI tools on each server. If you want to install them, you need to specify the AD DS tools by running the **Add-WindowsFeature** cmdlet with the **RSAT-ADDS** command.

> **Note**: You might need to wait after the installation process completes before verifying that the AD DS role has installed. If you do not observe the expected results from the **Get-WindowsFeature** command, you can try again after a few minutes.

#### Task 2: Prepare the AD DS installation and promote a remote server

1. On **SEA-ADM1**, from **Server Manager**, on the **All Servers** node, add **SEA-SVR1** as a managed server.
1. On **SEA-ADM1**, from **Server Manager**, configure **SEA-SVR1** as an AD DS domain controller by using the following settings:

   - Type: Additional domain controller for existing domain
   - Domain: `contoso.com`
   - Credentials: **CONTOSO\\Administrator** with the password **Pa55w.rd**
   - Directory Services Restore Mode (DSRM) password: **Pa55w.rd**
   - Do not remove the selections for DNS and the global catalog

1. On the **Review Options** page, select **View Script**.
1. In Notepad, edit the generated Windows PowerShell script as follows:

   - Delete the comment lines, which begin with the number sign (#).
   - Remove the Import-Module line.
   - Remove the grave accents (`) at the end of each line.
   - Remove the line breaks.

1. Now that the **Install-ADDSDomainController** command and all the parameters are on one line, copy the command.
1. Switch to the **Active Directory Domain Services Configuration Wizard**, and then select **Cancel**.
1. Switch to Windows PowerShell, and then at the command prompt, enter the following command:

   ```powershell
   Invoke-Command –ComputerName SEA-SVR1 { }
   ```
1. Paste the copied command between the braces ({ }) and run the resulting command to start the installation. The complete command should have the following format:

   ```powershell
 	Invoke-Command –ComputerName SEA-SVR1 {Install-ADDSDomainController -NoGlobalCatalog:$false -CreateDnsDelegation:$false -Credential (Get-Credential) -CriticalReplicationOnly:$false -DatabasePath "C:\Windows\NTDS" -DomainName "Contoso.com" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SiteName "Default-First-Site-Name" -SysvolPath "C:\Windows\SYSVOL" -Force:$true}
   ```

1. Provide the following credentials:

   - Username: **CONTOSO\\Administrator**
   - Password: **Pa55w.rd**

1. Set the **SafeModeAdministratorPassword** as **Pa55w.rd**.
1. After **SEA-SVR1** restarts, on **SEA-ADM1**, switch to **Server Manager**, and then select the **AD D** node. Note that **SEA-SVR1** has been added as a domain controller and that the warning notification has disappeared. You might have to select **Refresh**.

#### Task 3: Manage objects in AD DS

1. On **SEA-ADM1**, switch to the **Windows PowerShell** console.
1. To create an organizational unit (OU) called **Seattle**, in the **Windows PowerShell** console, run the following command:

   ```powershell
   New-ADOrganizationalUnit -Name "Seattle" -Path "DC=contoso,DC=com" -ProtectedFromAccidentalDeletion $true -Server SEA-DC1.contoso.com
   ```
1. To create a user account for **Ty Carlson** in the **Seattle** OU, run the following command:

   ```powershell
   New-ADUser -Name Ty -DisplayName 'Ty Carlson' -GivenName Ty -Surname Carlson -Path 'OU=Seattle,DC=contoso,DC=com'
   ```
1. To set the user's password to **Pa55w.rd**, run the following command:

   ```powershell
   Set-ADAccountPassword Ty
   ```

> **Note**: The current password is blank.

1. To enable the user account, run the following command:

   ```powershell
   Enable-ADAccount Ty
   ```
1. To create a domain global group named **SeattleBranchUsers**, run the following command:

   ```powershell
   New-ADGroup SeattleBranchUsers -Path 'OU=Seattle,DC=contoso,DC=com' -GroupScope Global -GroupCategory Security
   ```
1. To add the **Ty** user account to the newly created group, run the following command:

   ```powershell
   Add-ADGroupMember -Identity SeattleBranchUsers -Members Ty
   ```
1. To confirm that the user is in the group, run the following command:

   ```powershell
   Get-ADGroupMember -Identity SeattleBranchUsers
   ```
1. To add the user to the local Administrators group, run the following command:

   ```powershell
   Add-LocalGroupMember -Group 'Administrators' -Member 'CONTOSO\Ty'
   ```

   > **Note**: This is necessary to allow sign in with the **CONTOSO\\Ty** user account to **SEA-ADM1**.

### Results

After this exercise, you should have successfully created a new domain controller and managed objects in AD DS.

## Exercise 2: Configuring Group Policy

### Scenario

As a part of Group Policy implementation, you want to import custom administrative templates for Office apps and configure settings.

The main tasks for this exercise are as follows:

1. Create and edit GPO settings.
1. Apply and verify settings on the client computer.

### Task 1: Create and edit a GPO

1. On **SEA-ADM1**, from **Server Manager**, open the **Group Policy Management** console.
1. Create a GPO named **Contoso Standards** in the **Group Policy Objects** container.
1. Open the **Contoso Standards** GPO in the Group Policy Management Editor, and then browse to **User Configuration\Policies\Administrative Templates\System**.
1. Enable the **Prevent access to registry editing tools** policy setting.
1. Browse to the **User Configuration\Policies\Administrative Templates\Control Panel\Personalization** folder, and then configure the **Screen saver** timeout policy to **600** seconds.
1. Enable the **Password protect the screen saver** policy setting, and then close the **Group Policy Management Editor** window.

### Task 2: Link the GPO

  - Link the **Contoso Standards** GPO to the `contoso.com` domain.

### Task 3: Review the effects of the GPO’s settings

1. On **SEA-ADM1**, open **Control Panel**.
1. Use the **Windows Defender Firewall** interface to enable **Remote Event Log Management** domain traffic. 
1. Sign out, and then sign in as **CONTOSO\\Ty** with the password **Pa55w.rd**.
1. Attempt to change the screen saver wait time and resume settings. Verify that Group Policy blocks these actions.
1. Attempt to run Registry Editor. Verify that Group Policy blocks this action. 
1. Sign out and then sign in as **CONTOSO\\Administrator** with the password **Pa55w.rd**.

#### Task 4: Create and link the required GPOs

1. On **SEA-ADM1**, in the **Group Policy Management** console, create a new GPO named **Seattle Application Override** that is linked to the **Seattle** OU.
1. Configure the **Screen saver timeout** policy setting to be disabled, and then close the **Group Policy Management Editor** window.

### Task 5: Verify the order of precedence

1. On **SEA-ADM1**, from **Server Manager**, open the **Group Policy Management** console.
1. In the **Group Policy Management Console** tree, select the **Seattle** OU.
1. Select the **Group Policy Inheritance** tab and review its content.

   > **Note**: The Seattle Application Override GPO has higher precedence than the CONTOSO Standards GPO. The screen saver time-out policy setting that you just configured in the Seattle Application Override GPO is applied after the setting in the CONTOSO Standards GPO. Therefore, the new setting will overwrite the CONTOSO Standards GPO setting. Screen saver time-out will be disabled for users within the scope of the Seattle Application Override GPO.

### Task 6: Configure the scope of a GPO with security filtering

1. On **SEA-ADM1**, in the **Group Policy Management** console, select the **Seattle Application Override** GPO. Notice that in the **Security Filtering** section, the GPO applies by default to all authenticated users.
1. In the **Security Filtering** section, first remove **Authenticated Users**, and then add the **SeattleBranchUsers** group and the **SEA-ADM1** computer account.

### Task 7: Verify the application of settings

1. In Group Policy Management, in the navigation pane, select **Group Policy Modeling**.
1. Launch the **Group Policy Modeling Wizard**.
1. Set the target user and computer to the **CONTOSO\\Ty** user account and the **SEA-ADM1** computer, respectively.
1. Step through the remaining pages of the wizard, review the default settings without modifying them, and complete the wizard, which will generate a report containing its outcome.
1. After the report is created, in the details pane, select the **Details** tab, and then select **show all**.
1. In the report, scroll down until you locate the **User Details** section, and then locate the **Control Panel/Personalization** section. You should notice that the **Screen saver timeout** settings are obtained from the Seattle Application Override GPO.
1. Close the **Group Policy Management** console.

### Results

After this exercise, you should have successfully created and configured GPOs.
