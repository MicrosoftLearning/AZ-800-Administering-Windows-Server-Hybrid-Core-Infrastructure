---
lab:
    title: 'Lab: Using Windows Admin Center in hybrid scenarios'
    type: 'Answer Key'
    module: 'Module 4: Facilitating hybrid management'
---

# Lab answer key: Using Windows Admin Center in hybrid scenarios

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-800%20Lab%20Simulation%20-%20Using%20Windows%20Admin%20Center%20in%20hybrid%20scenarios)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Exercise 1: Provisioning Azure VMs running Windows Server

#### Task 1: Create an Azure resource group by using an Azure Resource Manager template

1. Connect to **SEA-ADM1**, and if needed, sign in with the credentials provided by the instructor.
1. On **SEA-ADM1**, start Microsoft Edge, go to the Azure portal at `https://portal.azure.com`, and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. In the Azure portal, open the Cloud Shell pane by selecting the toolbar icon directly next to the search text box.
1. If prompted to select either **Bash** or **PowerShell**, select **PowerShell**.

   >**Note**: If this is the first time you are starting Cloud Shell and you are presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and then select **Create storage**.

1. In the toolbar of the Cloud Shell pane, select the **Upload/Download files** icon, in the drop-down menu, select **Upload**, and then upload the **C:\\Labfiles\\Lab04\\L04-sub_template.json** file to the Cloud Shell home directory.
1. From the Cloud Shell pane, run the following commands to create a resource group that will contain the resources you provision in this lab. (Replace the `<Azure region>` placeholder with the name of an Azure region into which you can deploy Azure virtual machines, such as **eastus**.)

   >**Note**: This lab has been tested and verified using East US, so you should use that region. In general, to identify Azure regions where you can provision Azure VMs, refer to [Find Azure credit offers in your region](https://aka.ms/regions-offers).

   ```powershell
   $location = '<Azure region>'
   $rgName = 'AZ800-L0401-RG'
   New-AzSubscriptionDeployment `
     -Location $location `
     -Name az800l04subDeployment `
     -TemplateFile $HOME/L04-sub_template.json `
     -rgLocation $location `
     -rgName $rgName
   ```

#### Task 2: Create an Azure VM by using an Azure Resource Manager template

1. From the Cloud Shell pane, upload an Azure Resource Manager template **C:\\Labfiles\\Lab04\\L04-rg_template.json**.
1. From the Cloud Shell pane, run the following command to deploy an Azure VM running Windows Server that you'll be using in this lab:

   ```powershell
   New-AzResourceGroupDeployment `
     -Name az800l04rgDeployment `
     -ResourceGroupName $rgName `
     -TemplateFile $HOME/L04-rg_template.json
   ```

1. When prompted, insert the credentials provided by the instructor.

   >**Note**: Wait for the deployment to complete before you proceed to the next exercise. The deployment should take about 5 minutes.

1. In the Azure portal, close the Cloud Shell pane.
1. In the Azure portal, in the **Search resources, services, and docs** text box in the toolbar, search for and select the **az800l04-vnet** virtual network.
1. On the **az800l04-vnet** page, under **Settings** section, select **Subnets**, and then, on the **Subnets** page, select **+ ubnet**.
1. On the **Add subnet** page, settings pane, specify the following settings, and then select **Add** (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subnet purpose|**Virtual Network Gateway**|
   |Starting address|**10.4.3.224/27**|

## Exercise 2: Implementing hybrid connectivity by using the Azure Network Adapter

#### Task 1: Register Windows Admin Center with Azure

1. On **SEA-ADM1**, select **Start**, and then select **Windows PowerShell (Admin)**.

   >**Note**: Perform the next two steps in case you have not already installed Windows Admin Center on **SEA-ADM1**.

1. In the **Windows PowerShell** console, enter the following command, and then press Enter to download the latest version of Windows Admin Center:
	
   ```powershell
   Start-BitsTransfer -Source https://aka.ms/WACDownload -Destination "$env:USERPROFILE\Downloads\WindowsAdminCenter.exe"
   ```
1. Open a file explorer, navigate to the **Downloads** folder, and run the **WindowsAdminCenter.exe** file. This will start the **Windows Admin Center (v2) Installer** wizard.
1. On the **Welcome to the Windows Admin Center setup wizard** page, select **Next**.
1. On the **License Terms and Privacy Statement** page, **accept the terms** and select **Next**.
1. On the **Select installation mode** page, ensure **Express setup** is selected, and select **Next**.
1. On the **Select TLS certificate** page, ensure **Generate a self-signed certificate (expires in 60 days)** is selected, and select **Next**.
1. On the **Automatic updates** page, select **Notify me of available updates without downloading or installing them**, and select **Next**.
1. On the **Send diagnostic data to Microsoft** page, ensure **Required diagnostic data** is selected, and select **Next**.
1. Select **Install**, and when the installation is complete, ensure the **Start Windows Admin Center: `https://SEA-ADM1.contoso.com:443`** box is selected, and select **Finish**.

1. On **SEA-ADM1**, start Microsoft Edge, and then browse to `https://SEA-ADM1.contoso.com`.

   >**Note**: If the link does not work, on **SEA-ADM1**, open File Explorer, select Downloads folder, in the Downloads folder select **WindowsAdminCenter.msi** file and install manually. After the install completes, refresh Microsoft Edge.

   >**Note**: If you get **NET::ERR_CERT_DATE_INVALID** error, select **Advanced** on the Edge browser page, at the bottom of page select **Continue to sea-adm1-contoso.com (unsafe)**. 
   
1. If prompted, in the **Windows Security** dialog box, enter the credentials provided by the instructor, and then select **OK**.

1. On the **All connections** page, select the **sea-adm1.contoso.com** entry. 
1. In Windows Admin Center, select **Networks**, and then select **+ Add Azure Network Adapter (Preview)**.

   > **Note**: Depending on the screen resolution, you might need to select the **ellipsis** icon if the **Actions** menu is not available.

1. When prompted, in the **Add Azure Network Adapter** window, select **Register Windows Admin Center to Azure**.

   >**Note**: This will automatically display the Azure pane on the **Settings** page within Windows Admin Center.

1. In Windows Admin Center, in the Azure pane, on the **Settings** page, select **Register**.
1. In the **Get started with Azure in Windows Admin Center** pane, select **Copy** to copy the code displayed in the listing of the steps of the registration procedure. 
1. In the listing of step of the registration procedure, select the **Enter the code** link.

   >**Note**: This will open another tab in the Microsoft Edge window displaying the **Enter code** page.

1. In the **Enter code** text box, paste the code you copied into Clipboard, and then select **Next**.
1. On the **Sign in** page, provide the same username that you used to sign into your Azure subscription in the previous exercise, select **Next**, provide the corresponding password, and then select **Sign in**.
1. When prompted **Are you trying to sign in to Windows Admin Center?**, select **Continue**.
1. In Windows Admin Center, verify that the sign in was successful and close the newly opened tab of the Microsoft Edge window.
1. In the **Get started with Azure in Windows Admin Center** pane, ensure that **Microsoft Entra application** is set to **Create new**, and then select **Connect**.
1. In the listing of the steps of the registration procedure, select **Sign in**. This will open a pop-up window labeled **Permissions requested**.
   >Note: If you get an error message when signing in, try refreshing the page in previous step.
1. In the **Permissions requested** pop-up window, select **Consent on behalf of your organization**, and then select **Accept**.

#### Task 2: Create an Azure Network Adapter

>**Note**: Due to recent changes in the WAC console, this step is currently unavailable to execute.

## Exercise 3: Deploying Windows Admin Center gateway in Azure

#### Task 1: Install Windows Admin Center gateway in Azure

1. On **SEA-ADM1**, switch to the browser window displaying the Azure portal.
1. Back in the Azure portal, open the Cloud Shell pane by selecting the **Cloud Shell** icon.
1. In the toolbar of the Cloud Shell pane, select the **Upload/Download files** icon, in the drop-down menu, select **Upload**, and then upload the **C:\\Labfiles\\Lab04\\Deploy-WACAzVM.ps1** file into the Cloud Shell home directory.
1. From the Cloud Shell pane, run the following command to enable the compatibility for the **AzureRm** PowerShell cmdlets that are used by the Windows Admin Center provisioning script:

   ```powershell
   Enable-AzureRmAlias -Scope Process
   ```

1. From the Cloud Shell pane, run the following commands to set the values of variables necessary to run the Windows Admin Center provisioning script:

   ```powershell
   $rgName = 'AZ800-L0401-RG'
   $vnetName = 'az800l04-vnet'
   $nsgName = 'az800l04-web-nsg'
   $subnetName = 'subnet1'
   $location = 'eastus'
   $pipName = 'wac-public-ip'
   $size = 'Standard_D2s_v3'
   ```

1. From the Cloud Shell pane, run the following commands to set the script parameters variable:

   ```powershell
   $scriptParams = @{
     ResourceGroupName = $rgName
     Name = 'az800l04-vmwac'
     VirtualNetworkName = $vnetName
     SubnetName = $subnetName
     GenerateSslCert = $true
     size = $size
     PublicIPAddressName = $pipName
     SecurityGroupName = $nsgName
   }
   ```

1. From the Cloud Shell pane, run the following commands to disable certificate verification for PowerShell remoting (when prompted to confirm the installation from an untrusted repository, enter **A** and press Enter):

   ```powershell
   Install-Module -Name pswsman
   ```

   ```powershell
   Disable-WSManCertVerification -All
   ```

1. From the Cloud Shell pane, run the following command to launch the provisioning script:

   ```powershell
   ./Deploy-WACAzVM.ps1 @scriptParams
   ```

1. When prompted to provide the name for the local Administrator account, enter the **username** provided by the instructor.
1. When prompted to provide the password for the local Administrator account, enter the **password** provided by the instructor

   >**Note**: Wait for the provisioning script to complete. This might take about 5 minutes.
   
1. Close the Cloud Shell pane.
1. In the Azure portal, in the **Search resources, services, and docs** text box in the toolbar, search for and select **Virtual Machines**, and then, on the **Virtual Machines** page, select the **az800l04-vmwac** entry.
1. Under the **Connect** section, select **Connect** and then select **Download RDP file**.
1. When prompted, insert the credentials provided by the instructor.
1. Within the Remote Desktop session to **az800l04-vmwac** vm, select **Start**, and then select **Windows PowerShell (Admin)**.

1. In the **Windows PowerShell** console, enter the following command, and then press Enter to download the latest version of Windows Admin Center:
	
   ```powershell
   Start-BitsTransfer -Source https://aka.ms/WACDownload -Destination "$env:USERPROFILE\Downloads\WindowsAdminCenter.exe"
   ```
1. Open a file explorer, navigate to the **Downloads** folder, and run the **WindowsAdminCenter.exe** file. This will start the **Windows Admin Center (v2) Installer** wizard.
1. On the **Welcome to the Windows Admin Center setup wizard** page, select **Next**.
1. On the **License Terms and Privacy Statement** page, **accept the terms** and select **Next**.
1. On the **Select installation mode** page, ensure **Express setup** is selected, and select **Next**.
1. On the **Select TLS certificate** page, ensure **Generate a self-signed certificate (expires in 60 days)** is selected, and select **Next**.
1. On the **Automatic updates** page, select **Notify me of available updates without downloading or installing them**, and select **Next**.
1. On the **Send diagnostic data to Microsoft** page, ensure **Required diagnostic data** is selected, and select **Next**.
1. Select **Install**, and when the installation is complete, ensure the **Start Windows Admin Center: `https://az800l04-vmwac:443`** box is selected, and select **Finish**.

  >**Note**: The installation may take up to 5 minutes.

## Exercise 4: Verifying functionality of the Windows Admin Center gateway in Azure

#### Task 1: Connect to the Windows Admin Center gateway running in Azure VM

1. On **SEA-ADM1**, on the **az800l04-vmwac** page, select the **Overview** entry on the left menu and copy the **DNS Name**.
1. On **SEA-ADM1**, start Microsoft Edge and paste the **DNS Name** in the `https://` format.
1. In Microsoft Edge window, disregard the message **Your connection isn't private**, select **Advanced**, and then select the link starting with the text **Continue to**.
1. When prompted, in the **Sign in to access this site** dialog box, sign in with the credentials provided by the instructor.
1. On the **All connections** page of Windows Admin Center, select **az800l04-vmwac [Gateway]**.
1. Examine the Overview pane of Windows Admin Center.

#### Task 2: Enable PowerShell Remoting on an Azure VM

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal, and then, in the **Search resources, services, and docs** text box in the toolbar, search for and select **Virtual machines**.
1. On the **Virtual machines** page, select **az800l04-vm0**.
1. On the **az800l04-vm0** page, in the **Operations** section, select **Run command**, and then select **RunPowerShellScript**.
1. If Windows Remote Management is disabled, on the **Run Command Script** page, in the **PowerShell Script** section, enter the following command, and then select **Run** to enable it.

   ```powershell
   winrm quickconfig -quiet
   ```

1. In the **PowerShell Script** section, replace the text you entered in the previous step with the following command, and then select **Run** to open the Windows Remote Management inbound port:

   ```powershell
   Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
   ```

1. In the **PowerShell Script** section, replace the text you entered in the previous step with the following command, and then select **Run** to enable PowerShell Remoting:

   ```powershell
   Enable-PSRemoting -Force -SkipNetworkProfileCheck
   ```

#### Task 3: Connect to an Azure VM by using the Windows Admin Center gateway running in Azure VM

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the interface of the Windows Admin Center gateway running on the **az800l04-vmwac** Azure VM, select **Windows Admin Center**.
1. On the **All connections** page, select **+ Add**.
1. On the **Add or create resources** page, in the **Servers** section, select **Add**.
1. In the **Server name** text box, enter **az800l04-vm0**.
1. Select the **Use another account for this connection** option, provide the credentials provided by the instructor, and then select **Add with Credentials**.
1. In the list of connections, select **az800l04-vm0**
1. After successfully connecting to the Azure VM, examine the Overview pane of the **az800l04-vmwac** Azure VM in Windows Admin Center.

## Exercise 5: Deprovisioning the Azure environment

#### Task 1: Start a PowerShell session in Cloud Shell

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal.
1. In the Microsoft Edge window displaying the Azure portal, open the Cloud Shell pane by selecting the Cloud Shell icon.

#### Task 2: Identify all Azure resources provisioned in the lab

1. From the Cloud Shell pane, run the following command to list all the resource groups created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ800-L040*'
   ```

1. Run the following command to delete all the resource groups you created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ800-L040*' | Remove-AzResourceGroup -Force -AsJob
   ```

   >**Note**: The command executes asynchronously (as determined by the -AsJob parameter), so while you'll be able to run another PowerShell command immediately afterwards within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.
