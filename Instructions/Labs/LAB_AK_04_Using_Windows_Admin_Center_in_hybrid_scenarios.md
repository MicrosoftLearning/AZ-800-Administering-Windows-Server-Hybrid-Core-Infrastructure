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

1. Connect to **SEA-ADM1**, and if needed, sign in as **CONTOSO\\Administrator** with a password of **Pa55w.rd**.
1. On **SEA-ADM1**, start Microsoft Edge, go to the [Azure portal](https://portal.azure.com), and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
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

1. From the Cloud Shell pane, upload an Azure Resource Manager template **C:\\Labfiles\\Lab04\\L04-rg_template.json** and the corresponding Azure Resource Manager parameter file **C:\\Labfiles\\Lab04\\L04-rg_template.parameters.json**.
1. From the Cloud Shell pane, run the following command to deploy an Azure VM running Windows Server that you'll be using in this lab:

   ```powershell
   New-AzResourceGroupDeployment `
     -Name az800l04rgDeployment `
     -ResourceGroupName $rgName `
     -TemplateFile $HOME/L04-rg_template.json `
     -TemplateParameterFile $HOME/L04-rg_template.parameters.json
   ```

   >**Note**: Wait for the deployment to complete before you proceed to the next exercise. The deployment should take about 5 minutes.

1. In the Azure portal, close the Cloud Shell pane.
1. In the Azure portal, in the **Search resources, services, and docs** text box in the toolbar, search for and select the **az800l04-vnet** virtual network.
1. On the **az800l04-vnet** page, select **Subnets**, and then, on the **Subnets** page, select **+ Gateway subnet**.
1. On the **Add subnet** page, set the **Subnet address range** to **10.4.3.224/27**, and then select **Save** to create the **GatewaySubnet**.

## Exercise 2: Implementing hybrid connectivity by using the Azure Network Adapter

#### Task 1: Register Windows Admin Center with Azure

1. On **SEA-ADM1**, select **Start**, and then select **Windows PowerShell (Admin)**.

   >**Note**: Perform the next two steps in case you have not already installed Windows Admin Center on **SEA-ADM1**.

1. In the **Windows PowerShell** console, enter the following command, and then press Enter to download the latest version of Windows Admin Center:
	
   ```powershell
   Start-BitsTransfer -Source https://aka.ms/WACDownload -Destination "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"
   ```
1. Enter the following command, and then press Enter to install Windows Admin Center:
	
   ```powershell
   Start-Process msiexec.exe -Wait -ArgumentList "/i $env:USERPROFILE\Downloads\WindowsAdminCenter.msi /qn /L*v log.txt REGISTRY_REDIRECT_PORT_80=1 SME_PORT=443 SSL_CERTIFICATE_OPTION=generate"
   ```

   > **Note**: Wait until the installation completes. This should take about 2 minutes.

1. On **SEA-ADM1**, start Microsoft Edge, and then browse to `https://SEA-ADM1.contoso.com`.

   >**Note**: If the link does not work, on **SEA-ADM1**, browse to the **WindowsAdminCenter.msi** file, open the context menu for it, and then select **Repair**. After the repair completes, refresh Microsoft Edge. 
   
1. If prompted, in the **Windows Security** dialog box, enter the following credentials, and then select **OK**:

   - Username: **CONTOSO\\Administrator**
   - Password: **Pa55w.rd**

1. On the **All connections** page, select the **sea-adm1.contoso.com** entry. 
1. In Windows Admin Center, select **Networks**, select **Actions**, and then select **+ Add Azure Network Adapter (Preview)**.

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
1. In the **Get started with Azure in Windows Admin Center** pane, ensure that **Azure Active Directory application** is set to **Create new**, and then select **Connect**.
1. In the listing of the steps of the registration procedure, select **Sign in**. This will open a pop-up window labeled **Permissions requested**.
1. In the **Permissions requested** pop-up window, select **Consent on behalf of your organization**, and then select **Accept**.

#### Task 2: Create an Azure Network Adapter

1. On **SEA-ADM1**, back in the Microsoft Edge window displaying Windows Admin Center, browse to the **sea-adm1.contoso.com** page, and then select **Networks**.
1. In Windows Admin Center, on the **Networks** page, from the **Actions** menu, select the **+ Add Azure Network Adapter (Preview)** entry again.
1. In the **Add Azure Network Adapter** settings pane, specify the following settings, and then select **Create** (leave others with their default values):

   |Setting|Value|
   |---|---|
   |Subscription|The name of the Azure subscription you are using in this lab|
   |Location|eastus|
   |Virtual network|az800l04-vnet|
   |Gateway subnet|10.4.3.224/27|
   |Gateway SKU|VpnGw1|
   |Client Address Space|192.168.0.0/24|
   |Authentication Certificate|Auto-generated Self-signed root and client Certificate|

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, in the **Search resources, services, and docs** text box in the toolbar, search for and select **Virtual network gateways**.
1. On the **Virtual network gateways** page, select **Refresh** and verify that the new entry with the name starting with **WAC-Created-vpngw-96** appears in the list of virtual network gateways.

>**Note**: The provisioning of the Azure virtual network gateway can take up to 45 minutes. Do not wait for the provisioning to complete but instead proceed to the next exercise.

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
     PublicIPAddressName = $pipname
   }
   ```

1. From the Cloud Shell pane, run the following commands to disable certificate verification for PowerShell remoting (when prompted to confirm the installation from an untrusted repository, enter **A** and press Enter):

   ```powershell
   Install-Module -Name pswsman
   Disable-WSManCertVerification -All
   ```

1. From the Cloud Shell pane, run the following command to launch the provisioning script:

   ```powershell
   ./Deploy-WACAzVM.ps1 @scriptParams
   ```

1. When prompted to provide the name for the local Administrator account, enter **Student**
1. When prompted to provide the password for the local Administrator account, enter **Pa55w.rd1234**

   >**Note**: Wait for the provisioning script to complete. This might take about 5 minutes.

1. Verify that the script completed successfully and note the final message providing the URL containing the fully qualified name of the Azure VM that hosts the Windows Admin Center installation.

   >**Note**: Record the fully qualified name of the Azure VM. You will need it later in this lab.

1. Close the Cloud Shell pane.

#### Task 2: Review results of the script provisioning

1. In the Azure portal, in the **Search resources, services, and docs** text box in the toolbar, search for and select **Resource groups**, and then, on the **Resource groups** page, select the **AZ800-L0401-RG** entry.
1. On the **AZ800-L0401-RG** page, on the **Overview** page, review the list of resources, including the Azure VM **az800l04-vmwac**.
1. In the list of resources, select the Azure VM **az800l04-vmwac** entry, and then, on the **az800l04-vmwac** page, select **Networking**.
1. On the **az800l04-vmwac | Networking** page, on the **Inbound port rules** tab, note the entries representing the inbound port rule allowing connectivity on TCP port 5986 and the inbound rule allowing connectivity on TCP port 443.

## Exercise 4: Verifying functionality of the Windows Admin Center gateway in Azure

#### Task 1: Connect to the Windows Admin Center gateway running in Azure VM

1. On **SEA-ADM1**, start Microsoft Edge and go to the URL containing the fully qualified name of the target Azure VM hosting the Windows Admin Center installation you identified in the previous exercise.
1. In Microsoft Edge window, disregard the message **Your connection isn't private**, select **Advanced**, and then select the link starting with the text **Continue to**.
1. When prompted, in the **Sign in to access this site** dialog box, sign in with the **Student** username and **Pa55w.rd1234** password.
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
1. Select the **Use another account for this connection** option, provide the **Student** username and **Pa55w.rd1234** password, and then select **Add with Credentials**.
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
