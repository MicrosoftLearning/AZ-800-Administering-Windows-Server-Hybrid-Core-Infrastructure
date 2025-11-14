---
lab:
    title: 'Lab: Implementing integration between AD DS and Microsoft Entra ID'
    module: 'Module 2: Implementing Identity in Hybrid Scenarios'
---

# Lab: Implementing integration between AD DS and Microsoft Entra ID

## Scenario

To address concerns regarding management and monitoring overhead resulting from using Microsoft Entra ID to authenticate and authorize access to Azure resources, you decide to test integration between on-premises Active Directory Domain Services (AD DS) and Microsoft Entra ID to verify that this will address business concerns about managing multiple user accounts by using a mix of on-premises and cloud resources.

Additionally, you want to make sure that your approach addresses the Information Security team's concerns and preserves existing controls applied to Active Directory users, such as sign-in hours and password policies. Finally, you want to identify Microsoft Entra ID integration features that allow you to further enhance on-premises Active Directory security and minimize its management overhead, including Microsoft Entra ID Password Protection for Windows Server Active Directory and Self-Service Password Reset (SSPR) with password writeback.

Your goal is to implement pass-through authentication between on-premises AD DS and Microsoft Entra ID.

## Objectives

After completing this lab, you'll be able to:

- Prepare Microsoft Entra ID for integration with on-premises AD DS, including adding and verifying a custom domain.
- Prepare on-premises AD DS for integration with Microsoft Entra ID, including running IdFix DirSync Error Remediation Tool.
- Install and configure Microsoft Entra Connect.
- Verify integration between AD DS and Microsoft Entra ID by testing the synchronization process.
- Implementing Microsoft Entra ID integration features in Active Directory, including Microsoft Entra ID Password Protection for Windows Server Active Directory and SSPR with password writeback.

## Estimated time: 60 minutes

## Lab setup

Virtual machines: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, and **AZ-800T00A-ADM1** must be running. Other VMs can be running, but they aren't required for this lab. 

> **Note**: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, and **AZ-800T00A-SEA-ADM1** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, and **SEA-ADM1**

1. Select **SEA-ADM1**.
1. Sign in using the credentials provided by the instructor.

For this lab, you'll use the available VM environment and an Microsoft Entra tenant. Before you begin the lab, ensure that you have an Microsoft Entra tenant and a user account with the Global Administrator role in that tenant.

> **Important**: If you are creating a new Microsoft Entra tenant for this lab, please note that directory synchronization must be fully initialized before you can install Microsoft Entra Connect in Exercise 3. This initialization process typically takes 10-30 minutes after tenant creation. You can proceed with Exercises 1 and 2 while waiting for the directory synchronization to become ready. If you encounter the error "Directory synchronization is enabled for this directory, but has not yet taken effect" when installing Microsoft Entra Connect, wait an additional 15-30 minutes before trying again.

## Exercise 1: Preparing Microsoft Entra ID for AD DS integration

### Scenario

You need to ensure that your Microsoft Entra ID environment is ready for integration with your on-premises AD DS. Therefore, you'll create and verify a custom Microsoft Entra ID domain name and an account with the Global Administrator role.

The main tasks for this exercise are:

1. Create a custom domain name in Azure.
1. Create a user with the Global Administrator role.
1. Change the password for the user with the Global Administrator role.

#### Task 1: Create a custom domain name in Azure

1. On **SEA-ADM1**, start Microsoft Edge, and then go to the Azure portal.
1. Use the credentials that you instructor provides to sign in to the Azure portal.
1. In the Azure portal, browse to **Microsoft Entra ID**.
1. On the **Microsoft Entra ID** page, expand the **Manage** section in the left navigation pane, select **Custom domain names**, and then add `contoso.com`.
1. Review the DNS record types that you would use to verify the domain, and then close the pane without verifying the domain name.

   > **Note**: While, in general, you would use DNS records to verify a domain, this lab doesn't require the use of a verified domain.

#### Task 2: Create a user with the Global Administrator role

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the **Microsoft Entra ID** page, browse to the **All Users** page and create a user account with the following properties: 

   - Username: `admin`

   > **Note**: Ensure the domain name drop-down menu for the **User name** lists the default domain name ending with `onmicrosoft.com`. Record the complete username (for example, admin@contoso35501731.onmicrosoft.com) as you will need it to sign in later in this lab.

   - Name: **admin**
   - Role: **Global administrator**
   - Password: use autogenerated password

   > **Note**: Use the **Show Password** option to display the autogenerated password and record it as you'll use it later in this lab.

#### Task 3: Change the password for the user with the Global Administrator role

1. Sign out from the **Azure portal** and sign in with the user account you created in the previous task. 
1. When prompted, change the password.

   > **Note**: Record the complex password you used as you'll use it later in this lab.

## Exercise 2: Preparing on-premises AD DS for Microsoft Entra ID integration

### Scenario

You need to ensure that your existing Active Directory environment is ready for Microsoft Entra ID integration. Therefore, you'll run the IdFix tool, and then ensure that the UPNs of the Active Directory users match the Microsoft Entra tenant's custom domain name.

The main tasks for this exercise are:

1. Install IdFix.
1. Run IdFix.

#### Task 1: Install IdFix

1. On **SEA-ADM1**, open Microsoft Edge, and then go to `https://github.com/microsoft/idfix`.
1. On the **Github** page, under **ClickOnce Launch**, select **launch**.
1. In the **IdFix Privacy Statement** dialog box, review the disclaimer, and then select **OK**.

#### Task 2: Run IdFix

1. In the **IdFix** window, select **Query**.
1. Review the list of objects from the on-premises Active Directory, and review the **ERROR** and **ATTRIBUTE** columns. In this scenario, the value of **displayName** for **ContosoAdmin** is blank, and the tool's recommended new value appears in the **UPDATE** column.
1. In the **IdFix** window, in the **ACTION** drop-down menu, select **Edit**, and then select **Apply** to automatically implement the recommended changes.
1. In the **Apply Pending** dialog box, select **Yes**, and then close the IdFix tool.

## Exercise 3: Downloading, installing, and configuring Microsoft Entra Connect

### Scenario

Exercise scenario: You're now ready to implement the integration by downloading Microsoft Entra Connect, installing it on **SEA-ADM1**, and configuring its settings to match the integration objective.

> **Important**: Before proceeding with this exercise, ensure that sufficient time (at least 15-30 minutes) has passed since creating your Microsoft Entra tenant (if you created a new one). Directory synchronization must be fully initialized before installing Microsoft Entra Connect. If you encounter the error "Directory synchronization is enabled for this directory, but has not yet taken effect. Please wait until directory synchronization is ready," you need to wait longer before attempting the installation again.

The main task for this exercise is:

1. Install and configure Microsoft Entra Connect.

#### Task 1: Install and configure Microsoft Entra Connect

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, from the **Microsoft Entra ID** page, expand the **Manage** section in the left navigation pane, scroll down and select **Microsoft Entra Connect**, and then browse to the **Microsoft Entra Connect** page.
1. From the **Microsoft Entra Connect** page, select **Download**.
1. Download Microsoft Entra Connect installation binaries and start the installation.
1. On the **Microsoft Entra Connect** page, select the **I agree to the license terms and privacy notice** checkbox, and then select **Continue**.
1. On the **Express Settings** page, select **Use express settings**.
1. On the **Connect to Microsoft Entra ID** page, enter the username and password of the Microsoft Entra ID Global Administrator user account you created in exercise 1.
1. On the **Connect to AD DS** page, enter the credentials provided by the instructor.

1. On the **Microsoft Entra ID sign-in configuration** page, verify that the new domain you added is in the list of Active Directory UPN Suffixes.

   > **Note**: The domain name provided does not have to be a verified domain. While you typically would verify a domain prior to installing Microsoft Entra Connect, this lab doesn't require that verification step.

1. Select the **Continue without matching all UPN suffixes to verified domains** checkbox.
1. After you reach the **Ready to configure** page, review the list of actions, and then start the installation.

## Exercise 4: Verifying integration between AD DS and Microsoft Entra ID

### Scenario

Now that you have installed and configured Microsoft Entra Connect, you must verify its synchronization mechanism. You plan to make changes to an on-premises user account, which will trigger synchronization. Then, you'll verify that the change is replicated to the corresponding Microsoft Entra ID user object.

The main tasks for this exercise are:

1. Verify synchronization in the Azure portal.
1. Verify synchronization in the Synchronization Service Manager.
1. Update a user account in Active Directory.
1. Create a user account in Active Directory.
1. Sync changes to Microsoft Entra ID.
1. Verify changes in Microsoft Entra ID.

#### Task 1: Verify synchronization in the Azure portal

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal. 
1. Refresh the **Microsoft Entra Connect** page and review the information under **Provision from Active Directory**.
1. From the **Microsoft Entra ID** page, browse to the **Users** page.
1. Observe the list of users synced from Active Directory.

   > **Note**: After the directory synchronization starts, it can take 15 minutes for Active Directory objects to appear in the Microsoft Entra ID portal.

1. From the **Users** page, browse to the **Groups** page.
1. Review the list of groups synced from Active Directory.

#### Task 2: Verify synchronization in the Synchronization Service Manager

1. On **SEA-ADM1**, on the **Start** menu, expand **Microsoft Entra Connect**, and then select **Synchronization Service**.
1. In the **Synchronization Service Manager** window, under the **Operations** tab, review the tasks that were performed to sync the Active Directory objects.
1. Select the **Connectors** tab, and note the two connectors.

   > **Note**: One connector is for AD DS and the other is for the Microsoft Entra tenant. 

1. Close the **Synchronization Service Manager** window.

#### Task 3: Update a user account in Active Directory

1. On **SEA-ADM1**, in **Server Manager**, open **Active Directory Users and Computers**.
1. In **Active Directory Users and Computers**, expand the **Sales** organizational unit (OU), and then open the properties for **Sumesh Rajan**.
1. In the properties of the user, select the **Organization** tab.
1. In the **Job Title** text box, enter **Manager**, and then select **OK**.

#### Task 4: Create a user account in Active Directory

- Create the following user in the **Sales** OU:
   - First name: **Jordan**
   - Last name: **Mitchell**
   - User logon name: **Jordan**
   - Password: **Pa55w.rd**

#### Task 5: Sync changes to Microsoft Entra ID

1. On **SEA-ADM1**, start **Windows PowerShell** as Administrator.
1. In the **Windows PowerShell** console, run the following command to trigger synchronization:

   ```powershell
   Start-ADSyncSyncCycle
   ```

   > **Note**: After the synchronization cycle starts, it can take 15 minutes for Active Directory objects to appear in the Microsoft Entra ID portal.

#### Task 6: Verify changes in Microsoft Entra ID

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal and go back to the **Microsoft Entra ID** page.
1. From the **Microsoft Entra ID** page, browse to the **Users** page.
1. On the **All Users** page, search for the user **Sumesh**.
1. Open the properties page of the user **Sumesh Rajan**, and then verify that the **Job title** attribute has been synced from Active Directory.
1. In Microsoft Edge, go back to the **All Users** page.
1. On the **All Users** page, search for the user **Jordan**.
1. Open the properties page of the user **Jordan Mitchell**, and then review the attributes of the user account that have been synced from Active Directory.

## Exercise 5: Implementing Microsoft Entra ID integration features in AD DS

### Scenario

You want to identify Microsoft Entra ID integration features that will allow you to further enhance your on-premises Active Directory security and minimize its management overhead. You also want to implement Microsoft Entra ID Password Protection for Windows Server Active Directory and self-service password reset with password writeback.

The main tasks for this exercise are:

1. Enable self-service password reset in Azure.
1. Enable password writeback in Microsoft Entra Connect.
1. Enable pass-through authentication in Microsoft Entra Connect.
1. Verify pass-through authentication in Azure.
1. Install and register the Microsoft Entra ID Password Protection proxy service and DC agent.
1. Enable password protection in Azure.

#### Task 1: Enable self-service password reset in Azure

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, browse to the Microsoft Entra ID page, expand the **Manage** section in the left navigation pane, scroll down and select **Licenses**, and then activate the **Microsoft Entra ID P2** free trial.
   
   > **Note**: If you encounter issues activating the Microsoft Entra ID P2 free trial and receive error messages prompting you to set up a payment option, this may be due to organizational requirements for the tenant. In such cases, you can continue with the lab exercises that don't specifically require the P2 license features, or contact your administrator for assistance.
   
1. Assign an Microsoft Entra ID P2 license to the Microsoft Entra ID Global Administrator user account you created in exercise 1.
   
   > **Note**: To assign licenses, on the **Licenses** page, expand the **Manage** section in the left navigation pane, scroll down and select **All products**.
   
1. In the Azure portal, browse to the Microsoft Entra ID **Password reset** page.
1. On the **Password reset** page, note that you can select the scope of users to which to apply the configuration.

   > **Note**: Don't enable the password reset feature because it will break the configuration steps that are required later in this lab.

#### Task 2: Enable password writeback in Microsoft Entra Connect

1. On **SEA-ADM1**, open **Microsoft Entra Connect**.
1. In the **Microsoft Entra Connect** window, select **Configure**.
1. On the **Additional tasks** page, select **Customize synchronization options**.
1. On the **Connect to Microsoft Entra ID** page, enter the username and password of the Microsoft Entra ID Global Administrator user account you created in exercise 1.
1. On the **Optional features** page, select **Password writeback**.

   > **Note**: Password writeback is required for self-service password reset of Active Directory users. This allows passwords changed by users in Microsoft Entra ID to sync to the Active Directory.

1. On the **Ready to configure** page, review the list of actions to be performed, and then select **Configure**.
1. After the configuration completes, close the **Microsoft Entra Connect** window.

#### Task 3: Enable pass-through authentication in Microsoft Entra Connect

1. On **SEA-ADM1**, on the **Start** menu, expand **Microsoft Entra Connect**, and then select **Microsoft Entra Connect**.
1. In the **Microsoft Entra Connect** window, select **Configure**.
1. On the **Additional tasks** page, select **Change user sign-in**.
1. On the **Connect to Microsoft Entra ID** page, enter the username and password of the Microsoft Entra ID Global Administrator user account you created in exercise 1.
1. On the **User sign-in** page, select **Pass-through authentication**.
1. Verify that the **Enable single sign-on** checkbox is selected.
1. On the **Enable single sign-on** page, select **Enter credentials**.
1. In the **Forest credentials** dialog box, authenticate using the credentials provided by the instructor.

2. On the **Enable single sign-on** page, verify that there's a green check mark next to **Enter credentials**.
3. On the **Ready to configure** page, review the list of actions to be performed, and then select **Configure**.
4. After the configuration completes, close the **Microsoft Entra Connect** window.

#### Task 4: Verify pass-through authentication in Azure

1. On **SEA-ADM1**, from the **Microsoft Entra ID** page in the Azure portal, browse to the **Microsoft Entra Connect** page.
1. On the **Microsoft Entra Connect** page, review the information under **User Sign-In**.
1. Under **User Sign-In**, select **Seamless single sign-on**.
1. On the **Seamless single sign-on** page, review the on-premises domain name.
1. From the **Seamless single sign-on** page, browse to the **Passthrough Authentication** page.
1. On the **Passthrough Authentication** page, review the list of servers under **Authentication Agent**.

   > **Note**: To install the Microsoft Entra ID Authentication Agent on multiple servers in your environment, you can download its binaries from the **Pass-through authentication** page in the Azure portal.

#### Task 5: Install and register the Microsoft Entra ID Password Protection proxy service and DC agent

1. On **SEA-ADM1**, start Microsoft Edge, browse to the Microsoft Downloads website, browse to the **Microsoft Entra ID Password Protection for Windows Server Active Directory** page where you can download installers, and then select **Download**.
1. Download **AzureADPasswordProtectionProxySetup.exe** and **AzureADPasswordProtectionDCAgentSetup.msi** to **SEA-ADM1**.

   > **Note**: We recommend installing the proxy service on a server that isn't a domain controller. In addition, the proxy service should not be installed on the same server as the Microsoft Entra Connect agent. You will install the proxy service on **SEA-SVR1** and the Password Protection DC Agent on **SEA-DC1**.

1. On **SEA-ADM1**, in the **Windows PowerShell** console, run the following command to remove the Zone.Identifier alternate data stream indicating that files have been downloaded from internet:

   ```powershell
   Get-ChildItem -Path "$env:USERPROFILE\Downloads -File | Unblock-File
   ```
1. Run the following commands to create the **C:\Temp** directory on **SEA-SVR1**, copy the **AzureADPasswordProtectionProxySetup.exe** installer to that directory, and invoke the installation:

   ```powershell
   New-Item -Type Directory -Path '\\SEA-SVR1.contoso.com\C$\Temp' -Force
   Copy-Item -Path "$env:USERPROFILE\Downloads\AzureADPasswordProtectionProxySetup.exe" -Destination '\\SEA-SVR1.contoso.com\C$\Temp\'
   Invoke-Command -ComputerName SEA-SVR1.contoso.com -ScriptBlock { Start-Process -FilePath C:\Temp\AzureADPasswordProtectionProxySetup.exe -ArgumentList `/quiet /log C:\Temp\AzureADPPProxyInstall.log` -Wait }
   ```
1. Run the following commands to create the **C:\Temp** directory on **SEA-DC1**, copy the **AzureADPasswordProtectionDCAgentSetup.msi** installer to that directory, invoke the installation, and restart the domain controller after the installation completes:

   ```powershell
   New-Item -Type Directory -Path '\\SEA-DC1.contoso.com\C$\Temp' -Force
   Copy-Item -Path "$env:USERPROFILE\Downloads\AzureADPasswordProtectionDCAgentSetup.msi" -Destination '\\SEA-DC1.contoso.com\C$\Temp\'
   Invoke-Command -ComputerName SEA-DC1.contoso.com -ScriptBlock { Start-Process msiexec.exe -ArgumentList '/i C:\Temp\AzureADPasswordProtectionDCAgentSetup.msi /quiet /qn /norestart /log C:\Temp\AzureADPPInstall.log' -Wait }
   Restart-Computer -ComputerName SEA-DC1.contoso.com -Force
   ```
1. Run the following commands to validate that the installations resulted in the creation of services necessary to implement Microsoft Entra ID Password Protection:

   ```powershell
   Get-Service -Computer SEA-SVR1 -Name AzureADPasswordProtectionProxy | fl
   Get-Service -Computer SEA-DC1 -Name AzureADPasswordProtectionDCAgent | fl
   ```

   > **Note**: Verify that each service has the **Running** status.

1. Run the following command to start a PowerShell Remoting session to **SEA-SVR1**:

   ```powershell
   Enter-PSSession -ComputerName SEA-SVR1
   ```

1. Within the PowerShell Remoting session, run the following command to register the proxy service with Active Directory (replace the `<Azure_AD_Global_Admin>` placeholder with the fully-qualified user principal name of the Microsoft Entra ID Global Administrator user account you created in exercise 1):

   ```powershell
   Register-AzureADPasswordProtectionProxy -AccountUpn <Azure_AD_Global_Admin> -AuthenticateUsingDeviceCode
   ```

1. Follow the prompts to authenticate by using the Microsoft Entra ID Global Administrator user account you created in exercise 1. 
1. Exit the PowerShell Remoting session.
1. In the **Windows PowerShell** console, enter the following command, and then press Enter to start a PowerShell Remoting session to **SEA-DC1**:

   ```powershell
   Enter-PSSession -ComputerName SEA-DC1
   ```

1. Within the PowerShell Remoting session, run the following command to register the proxy service with Active Directory (replace the `<Azure_AD_Global_Admin>` placeholder with the fully-qualified user principal name of the Microsoft Entra ID Global Administrator user account you created in exercise 1):

   ```powershell
   Register-AzureADPasswordProtectionForest -AccountUpn <Azure_AD_Global_Admin> -AuthenticateUsingDeviceCode
   ```

1. Follow the prompts to authenticate by using the Microsoft Entra ID Global Administrator user account you created in exercise 1. 
1. Exit the PowerShell Remoting session.

#### Task 6: Enable password protection in Azure

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal, go back to the **Microsoft Entra ID** page, and then browse to its **Security** page.
1. On the **Security** page, select **Authentication methods**.
1. On the **Authentication methods** page, select **Password protection**.
1. On the **Password protection** page, enable **Enforce custom list**.
1. In the **Custom banned password list** text box, enter the following words (one per line):
 
   - **Contoso**
   - **London**

   > **Note**: The list of banned passwords should be words that are relevant to your organization.

1. Verify that the **Enable password protection on Windows Server Active Directory** setting is enabled. 
1. Verify that the **Mode** is set to **Audit** and save your changes.

## Exercise 6: Cleaning up

### Scenario

You want to disable synchronization from the on-premises Active Directory to Azure. This will involve removing Microsoft Entra Connect and disabling synchronization with Azure.

The main tasks for this exercise are:

1. Uninstall Microsoft Entra Connect.
1. Disable directory synchronization in Azure.

#### Task 1: Uninstall Microsoft Entra Connect

1. On **SEA-ADM1**, open **Control Panel**.
2. Use the **Uninstall or change a program** functionality to uninstall **Microsoft Entra Connect**.

#### Task 2: Disable directory synchronization in Azure

1. On **SEA-ADM1**, switch to the **Windows PowerShell** window.
1. In the **Windows PowerShell** console, run the following command to install the Microsoft Graph PowerShell SDK:

   ```powershell
   Install-Module -Name Microsoft.Graph -Force
   ```
1. Run the following command to connect to Microsoft Entra ID with the required permissions:

   ```powershell
   Connect-MgGraph -Scopes "Organization.ReadWrite.All"
   ```
1. When prompted, sign in with the credentials of the Global Administrator user account you created in exercise 1.
1. Run the following commands to disable directory synchronization in Azure:

   ```powershell
   $OrgID = (Get-MgOrganization).Id
   $params = @{ onPremisesSyncEnabled = $false }
   Update-MgOrganization -OrganizationId $OrgID -BodyParameter $params
   ```
1. Run the following command to verify that directory synchronization has been disabled:

   ```powershell
   Get-MgOrganization | Select-Object DisplayName, OnPremisesSyncEnabled
   ```

   > **Note**: The **OnPremisesSyncEnabled** property should now be **False**. It may take up to 72 hours for all synchronized users to be fully converted to cloud-only accounts.

### Prepare for the next module

End the lab when you're finished in preparation for the next module.
