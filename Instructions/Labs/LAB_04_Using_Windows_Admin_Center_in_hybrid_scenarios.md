---
lab:
    title: 'Lab: Using Windows Admin Center in hybrid scenarios'
    module: 'Module 4: Facilitating hybrid management'
---

# Lab: Using Windows Admin Center in hybrid scenarios

## Scenario

To address concerns regarding the consistent operational and management model, regardless of the location of managed systems, you'll test the capabilities of Windows Admin Center in the hybrid environment containing different versions of the Windows Server operating system running on-premises and in Microsoft Azure virtual machines (VMs).

Your goal is to verify that Windows Admin Center can be used in a consistent manner regardless of the location of managed systems.

## Objectives

After completing this lab, you'll be able to:

- Test hybrid connectivity by using Azure Network Adapter.
- Deploy Windows Admin Center gateway in Azure.
- Verify functionality of Windows Admin Center gateway in Azure.

## Estimated time: 90 minutes

## Lab setup

Virtual machines: **AZ-800T00A-SEA-DC1** and **AZ-800T00A-ADM1** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-800T00A-SEA-DC1** and **AZ-800T00A-SEA-ADM1** VMs are hosting the installation of **SEA-DC1** and **SEA-ADM1**

1. Select **SEA-ADM1**.
1. Sign in using the credentials provided by the instructor.

For this lab, you'll use the available VM environment and an Azure subscription. Before you begin the lab, ensure that you have an Azure subscription and a user account with the Owner or Contributor role in that subscription, as well as with the Global Administrator role in the Microsoft Entra tenant associated with that subscription.

## Exercise 1: Provisioning Azure VMs running Windows Server

### Scenario

You need to verify that you can establish hybrid connectivity between an on-premises server and an Azure virtual network. To start, you'll provision Azure VMs running Windows Server by using an Azure Resource Manager template.

The main tasks for this exercise are as follows:

1. Create an Azure resource group by using an Azure Resource Manager template.
1. Create an Azure VM by using an Azure Resource Manager template.

#### Task 1: Create an Azure resource group by using an Azure Resource Manager template

1. On **SEA-ADM1**, start Microsoft Edge, browse to the Azure portal, and authenticate with your Azure credentials.
1. In the Azure portal, open a PowerShell session in the Cloud Shell pane.
1. Upload the **C:\\Labfiles\\Lab04\\L04-sub_template.json** file to the Cloud Shell home directory.
1. From the Cloud Shell pane, run the following commands to create a resource group that will contain resources you provision in this lab. (Replace the `<Azure region>` placeholder with the name of an Azure region into which you can deploy Azure virtual machines, such as **eastus**.)

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
1. From the Cloud Shell pane, run the following command to deploy an Azure VM running Windows Server, which you'll be using in this lab:

   ```powershell
   New-AzResourceGroupDeployment `
     -Name az800l04rgDeployment `
     -ResourceGroupName $rgName `
     -TemplateFile $HOME/L04-rg_template.json `
     -TemplateParameterFile $HOME/L04-rg_template.parameters.json
   ```

   >**Note**: Wait for the deployment to complete before you proceed to the next exercise. The deployment should take about 5 minutes.

1. In the Azure portal, close the Cloud Shell pane.
1. In the Azure portal, add **GatewaySubnet** with the **10.4.3.224/27** IP address range to the **az800l04-vnet** virtual network.

## Exercise 2: Implementing hybrid connectivity by using the Azure Network Adapter

### Scenario

You need to verify that you can establish hybrid connectivity between an on-premises server and the Azure VM you provisioned in the previous exercise. You'll use the Azure Network Adapter feature of Windows Admin Center for this purpose.

The main tasks for this exercise are as follows:

1. Register Windows Admin Center with Azure.
1. Create an Azure Network Adapter.

#### Task 1: Register Windows Admin Center with Azure

1. On **SEA-ADM1**, start **Windows PowerShell** as Administrator.

   >**Note**: Perform the next two steps in case you have not already installed Windows Admin Center on **SEA-ADM1**.

1. In the **Windows PowerShell** console, run the following command, and then press Enter to download the latest version of Windows Admin Center:
	
   ```powershell
   Start-BitsTransfer -Source https://aka.ms/WACDownload -Destination "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"
   ```
1. Enter the following command, and then press Enter to install Windows Admin Center:
	
   ```powershell
   Start-Process msiexec.exe -Wait -ArgumentList "/i $env:USERPROFILE\Downloads\WindowsAdminCenter.msi /qn /L*v log.txt REGISTRY_REDIRECT_PORT_80=1 SME_PORT=443 SSL_CERTIFICATE_OPTION=generate"
   ```

   > **Note**: Wait until the installation completes. This should take about 2 minutes.

1. On **SEA-ADM1**, start Microsoft Edge and connect to the local instance of Windows Admin Center at `https://SEA-ADM1.contoso.com`. 

   >**Note**: If the link does not work, on **SEA-ADM1**, browse to the **WindowsAdminCenter.msi** file, open the context menu for it, and then select **Repair**. After the repair completes, refresh Microsoft Edge. 

1. If prompted, in the **Windows Security** dialog box, enter the credentials provided by the instructor, and then select **OK**.

1. From the Windows Admin Center page, attempt to add an Azure Network Adapter.
1. When prompted, register Windows Admin Center to the Azure subscription you used in the previous exercise.

#### Task 2: Create an Azure Network Adapter

1. On **SEA-ADM1**, in the Microsoft Edge window displaying Windows Admin Center, attempt to create an Azure Network Adapter again.
1. Create an Azure Network Adapter with the following settings:

   |Setting|Value|
   |---|---|
   |Subscription|The name of the Azure subscription you are using in this lab|
   |Location|eastus|
   |Virtual network|az800l04-vnet|
   |Gateway subnet|10.4.3.224/27|
   |Gateway SKU|VpnGw1|
   |Client Address Space|192.168.0.0/24|
   |Authentication Certificate|Auto-generated Self-signed root and client Certificate|

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal and verify that a new virtual network gateway with the name starting with **WAC-Created-vpngw-** is being provisioned.

   >**Note**: The provisioning of the Azure virtual network gateway can take up to 45 minutes. Do not wait for the provisioning to complete but instead proceed to the next exercise.

## Exercise 3: Deploying Windows Admin Center gateway in Azure

### Scenario

You need to evaluate the ability to manage Azure VMs running Windows Server OS by using Windows Admin Center. To accomplish this, you'll first install a Windows Admin Center gateway in the Azure virtual network you implemented in the first exercise of this lab.

The main tasks for this exercise are as follows:

1. Install Windows Admin Center gateway in Azure.
1. Review results of the script provisioning.

#### Task 1: Install Windows Admin Center gateway in Azure

1. On **SEA-ADM1**, switch to the browser window displaying the the Azure portal.
1. In the Azure portal, start a PowerShell session in the Cloud Shell pane.
1. From the Cloud Shell pane, upload the file **C:\\Labfiles\\Lab04\\Deploy-WACAzVM.ps1** into the Cloud Shell home directory.
1. From the Cloud Shell pane, run the following command to enable the compatibility for the **AzureRm** PowerShell cmdlets that are used by the Windows Admin Center provisioning script:

   ```powershell
   Enable-AzureRmAlias -Scope Process
   ```
1. Run the following commands to set values of variables necessary to run the the Windows Admin Center provisioning script (Replace the `<Azure region>` placeholder with the name of an Azure region into which you deploy resources earlier in this lab, such as **eastus**.):

   ```powershell
   $rgName = 'AZ800-L0401-RG'
   $vnetName = 'az800l04-vnet'
   $nsgName = 'az800l04-web-nsg'
   $subnetName = 'subnet1'
   $location = '<Azure region>'
   $pipName = 'wac-public-ip'
   $size = 'Standard_D2s_v3'
   ```
1. Run the following command to set the script parameters variable:

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
1. Run the following commands to disable certificate verification for PowerShell remoting (when prompted following the first command, enter **A** and press the Enter key):

   ```powershell
   install-module pswsman
   Disable-WSManCertVerification -All
   ```
1. Run the following command to launch the provisioning script:

   ```powershell
   ./Deploy-WACAzVM.ps1 @scriptParams
   ```
1. When prompted to provide the name for the local Administrator account, enter **Student**.
1. When prompted to provide the password for the local Administrator account, enter **Pa55w.rd1234**.

    >**Note**: Wait for the provisioning script to complete. This might take about 5 minutes.

1. Verify that the script completed successfully and note the final message providing the URL containing the fully qualified name of the Azure VM that hosts the Windows Admin Center installation.

   >**Note**: Record the fully qualified name of the Azure VM. You will need it later in this lab.

1. Close the Cloud Shell pane.

#### Task 2: Review results of the script provisioning

1. In the Azure portal, browse to the page of the **AZ800-L0401-RG** resource group.
1. On the **AZ800-L0401-RG** page, on the **Overview** page, review the list of resources, including the Azure VM **az800l04-vmwac**.
1. On the **az800l04-vmwac | Networking** page, on the **Inbound port rules** tab, note entries representing the inbound port rule allowing connectivity on TCP port 5986 and the inbound rule allowing connectivity on TCP port 443.

## Exercise 4: Verifying functionality of the Windows Admin Center gateway in Azure

### Scenario

With all required components in place, you'll test the WAC functionality targeting the Azure VMs deployed into the Azure virtual network you provisioned in the first exercise of this lab.

The main tasks for this exercise are as follows:

1. Connect to the Windows Admin Center gateway running in Azure VM.
1. Enable PowerShell Remoting on an Azure VM.
1. Connect to an Azure VM by using the Windows Admin Center gateway running in Azure VM.

#### Task 1: Connect to the Windows Admin Center gateway running in Azure VM

1. On **SEA-ADM1**, start Microsoft Edge and connect the Windows Admin Center gateway running in the Azure VM you identified in the previous exercise.
1. When prompted, sign in with the **Student** username and **Pa55w.rd1234** password.
1. On the All connections pane of Windows Admin Center, select **az800l04-vmwac [Gateway]**.
1. Examine the Overview pane of Windows Admin Center.

#### Task 2: Enable PowerShell Remoting on an Azure VM

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, browse to the page of the **az800l04-vm0** Azure VM.
1. From the **az800l04-vm0** page, use the **Run Command** feature to run the following command to enable Windows Remote Management in case it is disabled:

   ```powershell
   winrm quickconfig -quiet
   ```

1. Use the **Run Command** feature to run the following command to open Windows Remote Management inbound port:

   ```powershell
   Set-NetFirewallRule -Name WINRM-HTTP-In-TCP-PUBLIC -RemoteAddress Any
   ```

1. Use the **Run Command** feature to run the following command to enable PowerShell Remoting:

   ```powershell
   Enable-PSRemoting -Force -SkipNetworkProfileCheck
   ```

#### Task 3: Connect to an Azure VM by using the Windows Admin Center gateway running in Azure VM

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the interface of the Windows Admin Center gateway running on the **az800l04-vmwac** Azure VM, add a connection to the Azure VM **az800l04-vm0** by using its name.
1. When prompted, authenticate by using the credentials provided by the instructor.
1. After successfully connecting to the VM, examine the Overview pane of the **az800l04-vmwac** Azure VM in Windows Admin Center.

## Exercise 5: Deprovisioning the Azure environment

### Scenario

To minimize Azure-related charges, you'll deprovision the Azure resources provisioned throughout this lab.

The main tasks for this exercise are as follows:

1. Start a PowerShell session in Cloud Shell.
1. Identify all Azure resources provisioned in the lab.

#### Task 1: Start a PowerShell session in Cloud Shell

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal.
1. From the Azure portal, open a PowerShell session in the Cloud Shell pane.

#### Task 2: Identify all Azure resources provisioned in the lab

1. From the Cloud Shell pane, run the following command to list all resource groups created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'az800l04*'
   ```

1. Run the following command to delete all resource groups you created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'az800l04*' | Remove-AzResourceGroup -Force -AsJob
   ```

   >**Note**: The command executes asynchronously (as determined by the -AsJob parameter). So, while you'll be able to run another PowerShell command immediately afterwards within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.

### Results

After completing this lab, you have deployed and configured Azure VMs running Windows Server in a manner that satisfies the Contoso's manageability and security requirements.

### Prepare for the next module

End the lab when you're finished the preparation for the next module.
