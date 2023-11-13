---
lab:
    title: 'Lab: Implementing identity services and Group Policy'
    type: 'Answer Key'
    module: 'Module 1: Identity services in Windows Server'
---

# Lab answer key: Implementing identity services and Group Policy

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-800%20Lab%20Simulation%20-%20Implementing%20identity%20services%20and%20Group%20Policy)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Exercise 1: Deploying a new domain controller on Server Core

#### Task 1: Deploy AD DS on a new Windows Server Core server

1. Connect to **SEA-ADM1** and, if needed, sign in as **CONTOSO\Administrator** with a password of **Pa55w.rd**.
1. On **SEA-ADM1**, select **Start**, and then select **Windows PowerShell (Admin)**.
1. To install the AD DS server role, at the Windows PowerShell command prompt, enter the following command, and then press Enter:
	
   ```powershell
   Install-WindowsFeature –Name AD-Domain-Services –ComputerName SEA-SVR1
   ```
1. To verify that the AD DS role is installed on **SEA-SVR1**, enter the following command, and then press Enter:
	
   ```powershell
   Get-WindowsFeature –ComputerName SEA-SVR1
   ```
1. In the output of the previous command, search for the **Active Directory Domain Services** checkbox, and then verify that it is selected. Then, search for **Remote Server Administration Tools**. Notice the **Role Administration Tools** node below it, and then verify that the **AD DS and AD LDS Tools** node is also selected.

   > **Note**: Under the **AD DS and AD LDS Tools** node, only **Active Directory module for Windows PowerShell** has been installed and not the graphical tools, such as the Active Directory Administrative Center. If you centrally manage your servers, you will not usually need these on each server. If you want to install them, you must specify the AD DS tools by running the **Add-WindowsFeature** cmdlet with the **RSAT-ADDS** command.

   > **Note**: You might need to wait a brief time after the installation process is complete before verifying that the AD DS role has installed. If you do not observe the expected results from the **Get-WindowsFeature** command, you can try again after a few minutes.

#### Task 2: Prepare the AD DS installation and promote a remote server

1.  On **SEA-ADM1**, on the **Start** menu, select **Server Manager**, and then, in **Server Manager**, select the **All Servers** view.
1. On the **Manage** menu, select **Add Servers**.
1. In the **Add Servers** dialog box, maintain the default settings, and then select **Find Now**.
1. In the **Active Directory** list of servers, select **SEA-SVR1**, select the arrow to add it to the **Selected** list, and then select **OK**.
1. On **SEA-ADM1**, ensure that the installation of the AD DS role on **SEA-SRV1** is complete and that the server was added to **Server Manager**. Then select the **Notifications** flag symbol.
1. Note the post-deployment configuration of **SEA-SVR1**, and then select the **Promote this server to a domain controller** link.
1. In the **Active Directory Domain Services Configuration Wizard**, on the **Deployment Configuration** page, under **Select the deployment operation**, verify that **Add a domain controller to an existing domain** is selected.
1. Ensure that the `Contoso.com` domain is specified, and then in the **Supply the credentials to perform this operation** section, select **Change**.
1. In the **Credentials for deployment operation** dialog box, in the **User name** box, enter **CONTOSO\Administrator**, and then in the **Password** box, enter **Pa55w.rd**.
1. Select **OK**, and then select **Next**.
1. On the **Domain Controller Options** page, ensure that the **Domain Name System (DNS) server** and **Global Catalog (GC)** checkboxes are selected. Ensure that the **Read-only domain controller (RODC)** checkbox is cleared.
1. In the **Type the Directory Services Restore Mode (DSRM) password** section, enter and confirm the password **Pa55w.rd**, and then select **Next**.
1. On the **DNS Options** page, select **Next**.
1. On the **Additional Options** page, select **Next**.
1. On the **Paths** page, keep the default path settings for the **Database** folder, **Log files** folder, and **SYSVOL** folder, and then select **Next**.
1. To open the generated Windows PowerShell script, on the **Review Options** page, select **View script**.
1. In Notepad, edit the generated Windows PowerShell script:

   - Delete the comment lines that begin with the number sign (**#**).
   - Remove the **Import-Module** line.
   - Remove the grave accents (**`**) at the end of each line.
   - Remove the line breaks.

1. Now the **Install-ADDSDomainController** command and all the parameters are on one line. Place the cursor in front of the line, and then, on the **Edit** menu, select **Select All** to select the whole line. On the menu, select **Edit**, and then select **Copy**.

1. When prompted for confirmation, select **Yes** to cancel the wizard.
1. At the Windows PowerShell command prompt, enter the following command:

   ```powershell
   Invoke-Command –ComputerName SEA-SVR1 { }
   ```
1. Place the cursor between the braces (**{ }**), and then paste the content of the copied script line from the clipboard. The complete command should have the following format:
	
   ```powershell
   Invoke-Command –ComputerName SEA-SVR1 {Install-ADDSDomainController -NoGlobalCatalog:$false -CreateDnsDelegation:$false -Credential (Get-Credential) -CriticalReplicationOnly:$false -DatabasePath "C:\Windows\NTDS" -DomainName "Contoso.com" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SiteName "Default-First-Site-Name" -SysvolPath "C:\Windows\SYSVOL" -Force:$true}
   ```
1. To invoke the command, press Enter.
1. In the **Windows PowerShell Credential Request** dialog box, enter **CONTOSO\Administrator** in the **User name** box, enter **Pa55w.rd** in the **Password** box, and then select **OK**.
1. When prompted for the password, in the **SafeModeAdministratorPassword** text box, enter **Pa55w.rd**, and then press Enter.
1. When prompted for confirmation, in the **Confirm SafeModeAdministratorPassword** text box, enter **Pa55w.rd**, and then press Enter.
1. Wait until the command runs and the **Status Success** message is returned. The **SEA-SVR1** virtual machine restarts.
1. Close Notepad without saving the file.
1. After **SEA-SVR1** restarts, on **SEA-ADM1**, switch to **Server Manager**, and on the left side, select the **AD DS** node. Note that **SEA-SVR1** has been added as a server and that the warning notification has disappeared.

   > **Note**: You might have to select **Refresh**.

#### Task 3: Manage objects in AD DS

1. Ensure that you are connected to the console session of **SEA-ADM1**.
1. Switch to **Windows PowerShell (Admin)**.
1. To create an Organizational Unit (OU) called **Seattle** in the Contoso AD DS domain, enter the following command, and then press Enter:

   ```powershell
   New-ADOrganizationalUnit -Name "Seattle" -Path "DC=contoso,DC=com" -ProtectedFromAccidentalDeletion $true -Server SEA-DC1.contoso.com
   ```
1. To create a user account for **Ty Carlson** in the **Seattle** OU, enter the following command, and then press Enter:

   ```powershell
   New-ADUser -Name Ty -DisplayName 'Ty Carlson' -GivenName Ty -Surname Carlson -Path 'OU=Seattle,DC=contoso,DC=com'
   ```
1. To set the password for the Ty's user account, enter the following command, and then press Enter:

   ```powershell
   Set-ADAccountPassword Ty
   ```
1. When you receive a prompt for the current password, press Enter.
1. When you receive a prompt for the desired password, enter **Pa55w.rd**, and then press Enter.
1. When you receive a prompt to repeat the password, enter **Pa55w.rd**, and then press Enter.
1. To enable the account, enter the following command, and then press Enter:

   ```powershell
   Enable-ADAccount Ty
   ```
1. To create a domain global group named **SeattleBranchUsers**, enter the following command, and then press Enter:

   ```powershell
   New-ADGroup SeattleBranchUsers -Path 'OU=Seattle,DC=contoso,DC=com' -GroupScope Global -GroupCategory Security
   ```
1. To add the **Ty** user account to the newly created group, enter the following command, and then press Enter:

   ```powershell
   Add-ADGroupMember -Identity SeattleBranchUsers -Members Ty
   ```
1. To confirm that the user is in the group, enter the following command, and then press Enter:

   ```powershell
   Get-ADGroupMember -Identity SeattleBranchUsers
   ```
1. To add the user to the local Administrators group, enter the following command, and then press Enter:

   ```powershell
   Add-LocalGroupMember -Group 'Administrators' -Member 'CONTOSO\Ty'
   ```

   > **Note**: This is necessary to allow sign in with the **CONTOSO\\Ty** user account to **SEA-ADM1**.

**Results**: After this exercise, you should have successfully created a new domain controller and managed objects in AD DS.

## Exercise 2: Configuring Group Policy

#### Task 1: Create and edit a GPO

1. On **SEA-ADM1**, from Server Manager, select **Tools**, and then select **Group Policy Management**.
1. If necessary, switch to the **Group Policy Management** window.
1. In the **Group Policy Management** console, in the navigation pane, expand **Forest:Contoso.com**, **Domains**, and **Contoso.com**, and then select the **Group Policy Objects** container.
1. In the navigation pane, right-click or access the context menu for the **Group Policy Objects** container, and then select **New**.
1. In the **Name** text box, enter **CONTOSO Standards**, and then select **OK**.
1. In the details pane, right-click or access the context menu for the **CONTOSO Standards** Group Policy Object (GPO), and then select **Edit**.
1. In the **Group Policy Management Editor** window, in the navigation pane, expand **User Configuration**, expand **Policies**, expand **Administrative Templates**, and then select **System**.
1. Double-click the **Prevent access to registry editing tools** policy setting or select the setting, and then press Enter.
1. In the **Prevent access to registry editing tools** dialog box, select **Enabled**, and then select **OK**.
1. In the navigation pane, expand **User** **Configuration**, expand **Policies**, expand **Administrative Templates**, expand **Control Panel**, and then select **Personalization**.
1. In the details pane, double-click or select the **Screen saver timeout** policy setting, and then press Enter.
1. In the **Screen saver timeout** dialog box, select **Enabled**. In the **Seconds** text box, enter **600**, and then select **OK**. 
1. Double-click or select the **Password protect the screen saver** policy setting, and then press Enter.
1. In the **Password protect the screen saver** dialog box, select **Enabled**, and then select **OK**.
1. Close the **Group Policy Management Editor** window.

#### Task 2: Link the GPO

1. In the **Group Policy Management** window, in the navigation pane, right-click or access the context menu for the `Contoso.com` domain, and then select **Link an Existing GPO**.
1. In the **Select GPO** dialog box, select **CONTOSO Standards**, and then select **OK**.

#### Task 3: Review the effects of the GPO's settings

1. On **SEA-ADM1**, in the search box on the taskbar, enter **Control Panel**. 
1. In the **Best match** list, select **Control Panel**.
1. Select **System and Security**, and then select **Allow an app through Windows Firewall**.
1. In the **Allowed apps and features** list, locate the **Remote Event Log Management** entry, select the checkbox in the **Domain** column, and then select **OK**. 
1. Sign out, and then sign in as **CONTOSO\\Ty** with the password **Pa55w.rd**.
1. In the search box on the taskbar, enter **Control Panel**.
1. In the **Best match** list, select **Control Panel**.
1. In the search box in Control Panel, enter **screen saver**, and then select **Change screen saver**. (It might take a few minutes for the option to display.)
1. In the **Screen Saver Settings** dialog box, notice that the **Wait** option is dimmed. You cannot change the time-out. Notice that the **On resume, display logon screen** option is selected and dimmed and that you cannot change the settings.

   > **Note**: If the **On resume, display logon screen** option is not selected and dimmed, open a command prompt, run `gpupdate /force`, and repeat the preceding steps.

1. Right-click or access the context menu for **Start**, and then select **Run**.
1. In the **Run** dialog box, in the **Open** text box, enter **regedit**, and then select **OK**. Note the error message stating **Registry editing has been disabled by your administrator**.
1. In the **Registry Editor** dialog box, select **OK**.
1. Sign out and then sign in back as **CONTOSO\Administrator** with the password **Pa55w.rd**.

#### Task 4: Create and link the required GPOs

1. On **SEA-ADM1**, from Server Manager, select **Tools**, and then select **Group Policy Management**.
1. If necessary, switch to the **Group Policy Management** window.
1. In the **Group Policy Management** console, in the navigation pane, expand **Forest: Contoso.com**, **Domains**, and **Contoso.com**, and then select **Seattle**.
1. Right-click or access the context menu for the **Seattle** organizational unit (OU), and then select **Create a GPO in this domain, and Link it here**.
1. In the **New GPO** dialog box, in the **Name** text box, enter **Seattle Application Override**, and then select **OK**.
1. In the details pane, right-click or access the context menu for the **Seattle Application Override** GPO, and then select **Edit**.
1. In the **console** tree, expand **User Configuration**, expand **Policies**, expand **Administrative Templates**, expand **Control Panel**, and then select **Personalization**.
1. Double-click the **Screen saver timeout** policy setting or select the setting, and then press Enter.
1. Select **Disabled**, and then select **OK**.
1. Close the **Group Policy Management Editor** window.

#### Task 5: Verify the order of precedence

1. Back in the **Group Policy Management Console** tree, ensure that the **Seattle** OU is selected.
1. Select the **Group Policy Inheritance** tab and review its content.

   > **Note**: The Seattle Application Override GPO has higher precedence than the CONTOSO Standards GPO. The screen saver time-out policy setting that you just configured in the Seattle Application Override GPO is applied after the setting in the CONTOSO Standards GPO. Therefore, the new setting will overwrite the CONTOSO Standards GPO setting. Screen saver time-out will be disabled for users within the scope of the Seattle Application Override GPO.

#### Task 6: Configure the scope of a GPO with security filtering

1. On **SEA-ADM1**, in the **Group Policy Management** console, in the navigation pane, if necessary, expand the **Seattle** OU, and then select the **Seattle Application Override** GPO under the **Seattle** OU.
1. In the **Group Policy Management Console** dialog box, review the following message: **You have selected a link to a Group Policy Object (GPO). Except for changes to link properties, changes you make here are global to the GPO, and will impact all other locations where this GPO is linked.**
1. Select the **Do not show this message again** checkbox, and then select **OK**.
1. Review the **Security Filtering** section and note that the GPO applies by default to Authenticated Users.
1. In the **Security Filtering** section, select **Authenticated Users**, and then select **Remove**.
1. In the **Group Policy Management** dialog box, select **OK**, review the **Group Policy Management** warning, and then select **OK** again.

   > **Note**: Group Policy requires each computer account to have permissions to read GPO data from domain controllers to successfully apply the user GPO settings. You should keep it in mind when modifying security filtering settings of a GPO.

1. In the details pane, select **Add**.
1. In the **Select User, Computer, or Group** dialog box, in the **Enter the object name to select (examples):** text box, enter **SeattleBranchUsers**, and then select **OK**.
1. In the details pane, under **Security Filtering**, select **Add**.
1. In the **Select User, Computer, or Group** dialog box, select **Object Types**.
1. In the **Object Types** dialog box, select the **Computers** checkbox and then select **OK**.
1. In the **Select User, Computer, or Group** dialog box, in the **Enter the object name to select (examples):** text box, enter **SEA-ADM1**, and then select **OK**.

#### Task 7: Verify the application of settings

1. In the navigation pane, in **Group Policy Management**, select **Group Policy Modeling**.
1. Right-click or access the context menu for **Group Policy Modeling**, and then select **Group Policy Modeling Wizard**.
1. In **Group Policy Modeling Wizard**, select **Next**.
1. On the **Domain Controller Selection** page, accept the default settings, and then select **Next**.
1. On the **User and Computer Selection** page, in the **User information** section, select **User**, and then, in the **User** text box, enter **CONTOSO\Ty** or use the **Browse** command button to locate the **Ty** user account.
1. On the **User and Computer Selection** page, in the **Computer information** section, select **Computer**, and then, in the **Computer** text box, enter **CONTOSO\SEA-ADM1** or use the **Browse** command button to locate the **SEA-ADM1** computer.
1. On the **User and Computer Selection** page, select **Next**.
1. On the **Advanced Simulation Options** page, accept the default settings, and then select **Next**.
1. On the **Alternate Active Directory Paths** page, note the user and computer locations, and then select **Next**.
1. On the **User Security Groups** page, verify that the list of groups includes **CONTOSO\\SeattleBranchUsers**, and then select **Next**.
1. On the **Computer Security Groups** page, select **Next**.
1. On the **WMI Filters for Users** page, accept the default settings, and then select **Next**.
1. On the **WMI Filters for Computers** page, accept the default settings, and then select **Next**.
1. On the **Summary of Selections** page, select **Next**.
1. Select **Finish** when prompted.
1. In the details pane, select the **Details** tab, and then select **show all**.
1. In the report, scroll down until you locate the **User Details** section, and then locate the **Control Panel/Personalization** section. Note that the **Screen saver timeout** settings are disabled and the winning GPO is set to Seattle Application Override GPO.
1. Close the **Group Policy Management** console.

**Results**: After this exercise, you should have successfully created and configured GPOs.
