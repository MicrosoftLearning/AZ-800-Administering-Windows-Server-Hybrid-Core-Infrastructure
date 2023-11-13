---
lab:
    title: 'Lab: Implementing integration between AD DS and Microsoft Entra ID'
    type: 'Answer Key'
    module: 'Module 2: Implementing Identity in Hybrid Scenarios'
---

# Lab answer key: Implementing integration between AD DS and Microsoft Entra ID

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-800%20Lab%20Simulation%20-%20Implementing%20integration%20between%20AD%20DS%20and%20Azure%20AD)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Exercise 1: Preparing Microsoft Entra ID for AD DS integration

#### Task 1: Create a custom domain in Azure

1. Connect to **SEA-ADM1** and, if needed, sign in as **CONTOSO\Administrator** with a password of **Pa55w.rd**.
1. On **SEA-ADM1**, start Microsoft Edge, browse to the Azure portal, and authenticate with your Azure credentials.
1. In the Azure portal, browse to **Microsoft Entra ID**.
1. On the **Microsoft Entra ID** page, select **Custom domain names**.
1. On the **Custom domain names** page, select **Add custom domain**.
1. In the **Custom domain name** pane, in the **Custom domain name** text box, enter `contoso.com`, and then select **Add domain**.
1. On the **contoso.com** custom domain name page, review the Domain Name System (DNS) record types that you would use to verify the domain.
1. Close the pane without verifying the domain name.

   > **Note**: While, in general, you would use DNS records to verify a domain, this lab doesn't require the use of a verified domain.

#### Task 2: Create a user with the Global Administrator role

1. On **SEA-ADM1**, on the **Microsoft Entra ID** page in the Azure portal, select **Users**.
1. On the **All Users** page, select **+ New User**, from drop-down list select **Create new user**.
1. On the **Create new user** page, under **Identity**, in the **User principal name** and **Display name** text boxes, enter **admin**.

   > **Note**: Ensure the domain name drop-down menu for the **User principal nam** lists the default domain name ending with `onmicrosoft.com`.

1. In the **Password**, select the **Copy icon**, and record the password as you'll use it later in this lab.
1. Select **Next: Properties >**.
1. On the Properties tab, in the **Usage location** select **United States**, and then select **Next: Assignments >**.
1. On the **Assignments** tab, select **+ Add role**, and in the list of **Directory roles**, select **Global administrator** and then select the **Select** button.
1. On the **New user** page, select **Review + create**, and then select **Create**.

#### Task 3: Change the password for the user with the Global Administrator role

1. On the Azure portal, select your user account, and then select **Sign out**.
1. On the **Pick an account** page, select **Use another account**.
1. On the **Sign in** page, enter the fully-qualified username of the user account you previously created, and then select **Next**.
1. For the current password, use the password that you wrote down in the previous step.
1. Enter a complex password twice, and then select **Sign in**.

   > **Note**: Record the complex password you used as you'll use it later in this lab.

## Exercise 2: Preparing on-premises AD DS for Microsoft Entra ID integration

#### Task 1: Install IdFix

1. On **SEA-ADM1**, open Microsoft Edge, and then browse to `https://github.com/microsoft/idfix`.
1. On the **Github** page, under **ClickOnce Launch**, select **launch**.
1. On the status bar, select **Open file**.
1. In the **Application Install - Security Warning** dialog box, select **Install**.
1. In the **IdFix Privacy Statement** dialog box, review the disclaimer, and then select **OK**.

#### Task 2: Run IdFix

1. In the **IdFix** window, select **Query**.
1. If presented with the **Schema Warning** dialog box, select **Yes**.
1. Review the list of objects from Active Directory, and observe the **ERROR** and **ATTRIBUTE** columns. In this scenario, the value of **displayName** for **ContosoAdmin** is blank, and the tool's recommended new value appears in the **UPDATE** column.
1. In the **IdFix** window, from the **ACTION** drop-down menu, select **Edit**, and then select **Apply** to automatically implement the recommended changes.
1. In the **Apply Pending** dialog box, select **Yes**.
1. Close the IdFix tool.

## Exercise 3: Downloading, installing, and configuring Microsoft Entra Connect

#### Task 1: Install and configure Microsoft Entra Connect

   > **Note**: When you download the Microsoft Entra Connect application, the application still displays the older name, Azure AD Connect.

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, browse to **Microsoft Entra ID**.
1. On the **Microsoft Entra ID** page, select **Microsoft Entra Connect**.
1. On the **Microsoft Entra Connect | Get started** page, select **Connect Sync**.
1. On the **Microsoft Entra Connect | Connect Sync** page, select **Download Microsoft Entra Connect**.
1. On the newly opened page, under **Azure AD Connect V2**, select **Download**.
1. On the status bar, select **Open file**.
1. On the **Microsoft Azure Active Directory Connect** page, select the **I agree to the license terms and privacy notice** checkbox, and then select **Continue**.
1. On the **Express Settings** page, select **Use express settings**.
1. On the **Connect to Azure AD** page, enter the username and password of the Azure AD Global Administrator user account you created in exercise 1, and then select **Next**.
1. In the Sign-in to your account page, sign-in with the newly created user, and then select **Next**.

1. On the **Connect to AD DS** page, enter the following credentials, and then select **Next**:

   - Username: `CONTOSO\Administrator`
   - Password: `Pa55w.rd`

1. On the **Azure AD sign-in configuration** page, note that the new domain you added is in the list of Active Directory UPN Suffixes, but its status is listed as **Not verified**.

   > **Note**: The domain name provided does not have to be a verified domain. While you typically would verify a domain prior to installing Microsoft Entra Connect, this lab doesn't require that verification step.

1. Select the **Continue without matching all UPN suffixes to verified domains** checkbox, and then select **Next**.
1. On the **Ready to configure** page, review the list of actions, and then select **Install**.
1. On the **Configuration complete** page, select **Exit**.

## Exercise 4: Verifying integration between AD DS and Microsoft Entra ID

#### Task 1: Verify synchronization in the Azure portal

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal. 
1. Refresh the **Microsoft Entra Connect** page and review the information under **Provision from Active Directory**.
1. On the **Microsoft Entra ID** page, select **Users**.
1. Note that the user list includes users synced from Active Directory.

   > **Note**: After the directory synchronization starts, it can take 15 minutes for Active Directory objects to appear in the Microsoft Entra ID portal.

1. In Microsoft Edge, go back to the **Microsoft Entra ID** page.
1. On the **Microsoft Entra ID** page, select **Groups**.
1. Note the list of groups synced from Active Directory. 


#### Task 2: Update a user account in Active Directory

1. On **SEA-ADM1**, in Server Manager, on the **Tools** menu, select **Active Directory Users and Computers**.
1. In **Active Directory Users and Computers**, expand the **Sales** organizational unit (OU), and then open the properties for **Sumesh Rajan**.
1. In the properties of the user, select the **Organization** tab.
1. In the **Job Title** text box, enter **Manager**, and then select **OK**.

#### Task 3: Create a user account in Active Directory

1. In **Active Directory Users and Computers**, right-click or access the context menu for the **Sales** OU, select **New**, and then select **User**.
1. In the **New Object - User** window, enter the following user details for each field, and then select **Next**:

   - First name: **Jordan**
   - Last name: **Mitchell**
   - User logon name: **Jordan**

1. In the **Password** and **Confirm password** fields, enter **Pa55w.rd**, and then select **Next**.
1. Select **Finish**.

#### Task 4: Sync changes to Microsoft Entra ID

1. On **SEA-ADM1**, on the **Start** menu, select **Windows PowerShell**.
1. In the **Windows PowerShell** console, enter the following command, and then press Enter to trigger synchronization:

   ```powershell
   Start-ADSyncSyncCycle
   ```

   > **Note**: Once the synchronization cycle starts, it can take 15 minutes for Active Directory objects to appear in the Microsoft Entra ID portal.

#### Task 5: Verify changes in Microsoft Entra ID

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal and go back to the **Microsoft Entra ID** page.
1. On the **Microsoft Entra ID** page, select **Users**.
1. On the **All Users** page, search for the user **Sumesh**.
1. Open the properties page of the user **Sumesh Rajan**, and then verify that the **Job title** attribute has been synced from Active Directory.
1. In Microsoft Edge, go back to the **All Users** page.
1. On the **All Users** page, search for the user **Jordan**.
1. Open the properties page of the user **Jordan Mitchell** and review the attributes of the user account that was synced from Active Directory.


## Exercise 5: Implementing Microsoft Entra ID integration features in AD DS

#### Task 1: Enable self-service password reset in Azure

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, browse to the **Microsoft Entra ID** page.
1. On the **Microsoft Entra ID** page, select **Licenses**.
1. On the **Licenses** page, select **All products**.
1. On the **All products** page, select **+ Try/Buy**.
1. On the **Activate** page, under **Microsoft Entra ID P2**, select **Free trial**, and then select **Activate**.
1. Browse to the **All products** page and select **Microsoft Entra ID P2**.
1. On the **Microsoft Entra ID P2 \| Licensed users** page, select **+ Assign**.
1. On the **Assign license** page, select **+ Add users and groups**.
1. On the **Add users and groups** page, search for **admin**, select the **admin** account from the list of results, and then select **Select**.
1. Back on the **Assign license** page, select **Review + assign**, and then select **Assign**.

   > **Note**: This is necessary in order to implement Microsoft Entra ID password protection later in this lab.

1. Go back to the **Microsoft Entra ID** page.
1. On the **Microsoft Entra ID** page, select **Password reset**.
1. On the **Password reset** page, note that you can select the scope of users to which to apply the configuration.

   > **Note**: Don't enable the password reset feature because it will break the configuration steps that are required later in this lab.

#### Task 2: Enable password writeback in Microsoft Entra Connect

1. On **SEA-ADM1**, on the **Start** menu, search and select **Azure Ad Connect**.
1. In the **Microsoft Azure Active Directory Connect** window, select **Configure**.
1. On the **Additional tasks** page, select **Customize synchronization options**, and then select **Next**.
1. On the **Connect to Azure AD** page, enter the username and password of the Azure AD Global Administrator user account you created in exercise 1, and then select **Next**.
1. On the **Connect your directories** page, select **Next**.
1. On the **Domain and OU filtering** page, select **Next**.
1. On the **Optional features** page, select **Password writeback**, and then select **Next**.

   > **Note**: Password writeback is required for self-service password reset of Active Directory users. This allows passwords changed by users in Microsoft Entra ID to sync to the Active Directory.

1. On the **Ready to configure** page, review the list of actions to be performed, and then select **Configure**.
1. On the **Configuration complete** page, select **Exit**.

#### Task 3: Enable pass-through authentication in Microsoft Entra Connect

1. On **SEA-ADM1**, on the **Start** menu, search and select **Azure Ad Connect**.
1. In the **Microsoft Azure Active Directory Connect** window, select **Configure**.
1. On the **Additional tasks** page, select **Change user sign-in**, then select **Next**.
1. On the **Connect to Azure AD** page, enter the username and password of the Azure AD Global Administrator user account you created in exercise 1, and then select **Next**.
1. On the **User sign-in** page, select **Pass-through authentication**.
1. Verify that the **Enable single sign-on** checkbox is selected, and then select **Next**.
1. On the **Enable single sign-on** page, select **Enter credentials**.
1. In the **Forest credentials** dialog box, enter the following credentials, and then select **OK**:

   - Username: `Administrator`
   - Password: `Pa55w.rd`

1. On the **Enable single sign-on** page, verify that there's a green check mark next to **Enter credentials**, and then select **Next**.
1. On the **Ready to configure** page, review the list of actions to be performed, and then select **Configure**.
1. On the **Configuration complete** page, select **Exit**.

#### Task 4: Verify pass-through authentication in Azure

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal and go back to the **Microsoft Entra ID** page.
1. On the **Microsoft Entra ID** page in the Azure portal, select **Microsoft Entra Connect**.
1. On the **Microsoft Entra Connect | Get started** page, select **Connect Sync**.
1. On the **Microsoft Entra Connect | Connect Sync** page, review the information under **User Sign-In**.
1. Under **User Sign-In**, select **Seamless single sign-on**.
1. On the **Seamless single sign-on** page, note the on-premises domain name.
1. In Microsoft Edge, go back to the **Microsoft Entra Connect** page.
1. On the **Microsoft Entra Connect** page, under **User Sign-In**, select **Pass-through authentication**.
1. On the **Passthrough Authentication** page, note the **SEA-ADM1** server name under **Authentication Agent**.

   > **Note**: To install the Microsoft Entra ID Authentication Agent on multiple servers in your environment, you can download its binaries from the **Pass-through authentication** page in the Azure portal. 

#### Task 5: Install and register the Azure AD Password Protection proxy service and DC agent

1. On **SEA-ADM1**, start Microsoft Edge, go to the `https://www.microsoft.com/en-us/download/details.aspx?id=57071`.
1. On the **Azure AD Password Protection** page, select **Download**.
1. On the **Choose the download you want** page, select the **AzureADPasswordProtectionProxySetup.exe** and the **AzureADPasswordProtectionDCAgentSetup.msi** files, and then select **Download**.
1. In the **Download multiple files** dialog box, select **Allow**.

   > **Note**: We recommend installing the proxy service on a server that isn't a domain controller. In addition, the proxy service should not be installed on the same server as the Microsoft Entra Connect agent. You will install the proxy service on **SEA-SVR1** and the Password Protection DC Agent on **SEA-DC1**.

1. On **SEA-ADM1**, switch to the **Windows PowerShell** console window.
1. In the **Windows PowerShell** console, enter the following command, and then press Enter to remove the Zone.Identifier alternate data stream indicating that files have been downloaded from internet:

   ```powershell
   Get-ChildItem -Path "$env:USERPROFILE\Downloads" -File | Unblock-File
   ```
1. Run the following commands to create the **C:\Temp** directory on **SEA-SVR1**, copy the **AzureADPasswordProtectionProxySetup.exe** installer to that directory, and then invoke the installation:

   ```powershell
   New-Item -Type Directory -Path '\\SEA-SVR1.contoso.com\C$\Temp' -Force
   Copy-Item -Path "$env:USERPROFILE\Downloads\AzureADPasswordProtectionProxySetup.exe" -Destination '\\SEA-SVR1.contoso.com\C$\Temp\'
   Invoke-Command -ComputerName SEA-SVR1.contoso.com -ScriptBlock { Start-Process -FilePath C:\Temp\AzureADPasswordProtectionProxySetup.exe -ArgumentList '/quiet /log C:\Temp\AzureADPPProxyInstall.log' -Wait }
   ```
1. Run the following commands to create the **C:\Temp** directory on **SEA-DC1**, copy the **AzureADPasswordProtectionDCAgentSetup.msi** installer to that directory, invoke the installation, and restart the domain controller after the installation completes:

   ```powershell
   New-Item -Type Directory -Path '\\SEA-DC1.contoso.com\C$\Temp' -Force
   Copy-Item -Path "$env:USERPROFILE\Downloads\AzureADPasswordProtectionDCAgentSetup.msi" -Destination '\\SEA-DC1.contoso.com\C$\Temp\'
   Invoke-Command -ComputerName SEA-DC1.contoso.com -ScriptBlock { Start-Process msiexec.exe -ArgumentList '/i C:\Temp\AzureADPasswordProtectionDCAgentSetup.msi /quiet /qn /norestart /log C:\Temp\AzureADPPInstall.log' -Wait }
   Restart-Computer -ComputerName SEA-DC1.contoso.com -Force
   ```
1. Run the following commands to validate that the installations resulted in the creation of services necessary to implement Azure AD Password Protection:

   ```powershell
   Get-Service -Computer SEA-SVR1 -Name AzureADPasswordProtectionProxy | fl
   Get-Service -Computer SEA-DC1 -Name AzureADPasswordProtectionDCAgent | fl
   ```

   > **Note**: Verify that each service has the **Running** status.

1. In the **Windows PowerShell** console, enter the following command and press Enter to start a PowerShell Remoting session to **SEA-SVR1**:

   ```powershell
   Enter-PSSession -ComputerName SEA-SVR1
   ```

1. From the **[SEA-SVR1]** prompt, enter the following command and press Enter to register the proxy service with Active Directory (replace the `<Azure_AD_Global_Admin>` placeholder with the fully-qualified user principal name of the AD Global Administrator account you created in exercise 1):

   ```powershell
   Register-AzureADPasswordProtectionProxy -AccountUpn <Azure_AD_Global_Admin> -AuthenticateUsingDeviceCode
   ```

1. As instructed, open another Microsoft Edge window, browse to `https://microsoft.com/devicelogin` and when prompted, enter the code included in the message displayed in the PowerShell Remoting session. 
1. When prompted, authenticate by using the Azure AD Global Administrator user account you created in exercise 1, and then select **Continue**.
1. Switch back to the PowerShell Remoting session, enter the following command and press Enter to exit the PowerShell Remoting session to **SEA-SVR1**:

   ```powershell
   Exit-PSsession
   ```

1. In the **Windows PowerShell** console, enter the following command and press Enter to start a PowerShell Remoting session to **SEA-DC1**:

   ```powershell
   Enter-PSSession -ComputerName SEA-DC1
   ```

1. From the **[SEA-DC1]** prompt, enter the following command and press Enter to register the proxy service with Active Directory (replace the `<Azure_AD_Global_Admin>` placeholder with the fully-qualified user principal name of the Azure AD Global Administrator user account you created in exercise 1):

   ```powershell
   Register-AzureADPasswordProtectionForest -AccountUpn <Azure_AD_Global_Admin> -AuthenticateUsingDeviceCode
   ```

1. As instructed, open another Microsoft Edge window, browse to `https://microsoft.com/devicelogin` and when prompted, enter the code included in the message displayed in the PowerShell Remoting session. 
1. When prompted, authenticate by using the Microsoft Entra ID Global Administrator user account you created in exercise 1, and then select **Continue**.
1. Switch back to the PowerShell Remoting session, enter the following command, and then press Enter to exit the PowerShell Remoting session to **SEA-DC1**:

   ```powershell
   Exit-PSsession
   ```

#### Task 6: Enable password protection in Azure

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal, go back to the **Microsoft Entra ID** page. 
1. On the **Microsoft Entra ID** page, select **Security**.
1. On the **Security** page, select **Authentication methods**.
1. On the **Authentication methods** page, select **Password protection**.
1. On the **Password protection** page, change the **Enforce custom list** to **Yes**.
1. In the **Custom banned password list** text box, enter the following words (one per line):
 
   - **Contoso**
   - **London**

   > **Note**: The list of banned passwords should be words that are relevant to your organization.

1. Verify that the **Enable password protection on Windows Server Active Directory** is set to **Yes**.
1. Verify that the **Mode** is set to **Audit**, and then select **Save**.

## Exercise 6: Cleaning up

#### Task 1: Uninstall Azure AD Connect

1. On **SEA-ADM1**, on the **Start** menu, select **Control Panel**.
1. In the **Control Panel** window, under **Programs**, select **Uninstall a program**.
1. In the **Uninstall or change a program** window, select **Azure AD Connect**, and then select **Uninstall**.
1. In the **Programs and features** dialog box, select **Yes**.
1. In the **Uninstall Azure AD Connect** window, select **Remove**.
1. After Azure AD Connect is uninstalled, in the **Uninstall Azure AD Connect** window, select **Exit**.

#### Task 2: Disable directory synchronization in Azure

1. On **SEA-ADM1**, switch to the **Windows PowerShell** console window.
1. In the **Windows PowerShell** console, enter the following command and press Enter to install the Microsoft Online module for Microsoft Entra ID:

   ```powershell
   Install-Module -Name MSOnline
   ```
1. When prompted to install the NuGet provider, enter **Y**, and then press Enter.
1. When prompted to install the modules from an untrusted repository, enter **A**, and then press Enter.
1. In the **Windows PowerShell** console, enter the following command, and then press Enter to store Azure AD credentials in a variable:

   ```powershell
   $msolCred = Get-Credential
   ```
1. In the **Windows PowerShell credential request** dialog box, enter the credentials of the Azure AD Global Administrator user account you created in exercise 1, and then select **OK**.
1. In the **Windows PowerShell** console, enter the following command, and then press Enter to authenticate to the Microsoft Entra tenant:

   ```powershell
   Connect-MsolService -Credential $msolCred
   ```
1. Enter the following command and press Enter to disable directory synchronization:

   ```powershell
   Set-MsolDirSyncEnabled -EnableDirSync $false
   ```
1. When prompted to confirm, enter **Y**, and then press Enter.
