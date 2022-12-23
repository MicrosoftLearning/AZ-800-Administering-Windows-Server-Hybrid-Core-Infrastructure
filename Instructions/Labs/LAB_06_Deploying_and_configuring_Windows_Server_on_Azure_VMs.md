---
lab:
    title: 'Lab: Deploying and configuring Windows Server on Azure VMs'
    module: 'Module 6: Deploying and Configuring Azure VMs'
---

# Lab: Deploying and configuring Windows Server on Azure VMs

## Scenario

You need to address concerns regarding your current infrastructure. You have an outdated operational model, a limited use of automation, and Information Security team concerns regarding additional controls that should be applied to Azure VMs running Windows Server-based workloads. You have decided to develop and implement an automated deployment and configuration process for Azure VMs running Windows Server.

The process will involve Azure Resource Manager (ARM) templates and OS configuration through Azure VM extensions. It will also incorporate additional security protection mechanisms beyond those already applied to on-premises systems, such as application allow lists through AppLocker, file integrity checks, and adaptive network/DDoS protection. You will also leverage JIT functionality to restrict administrative access to Azure VMs to public IP address ranges associated with the London headquarters.

Your goal is to deploy and configure Azure VMs running Windows Server in the manner that satisfies manageability and security requirements.

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-800%20Lab%20Simulation%20-%20Deploying%20and%20configuring%20Windows%20Server%20on%20Azure%20VMs)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Objectives

After completing this lab, you'll be able to:

- Author ARM templates for an Azure VM deployment.
- Modify ARM templates to include VM extension-based configuration.
- Deploy Azure VMs running Windows Server by using ARM templates.
- Configure administrative access to Azure VMs running Windows Server.
- Configure Windows Server security in Azure VMs.
- Deprovision the Azure environment.

## Estimated time: 90 minutes

## Lab setup

Virtual machines: **AZ-800T00A-SEA-DC1** and **AZ-800T00A-ADM1** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-800T00A-SEA-DC1** and **AZ-800T00A-SEA-ADM1** virtual machines are hosting the installation of **SEA-DC1** and **SEA-ADM1**.

1. Select **SEA-ADM1**.
1. Sign in using the following credentials:

   - Username: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment and an Azure subscription. Before you begin the lab, ensure that you have an Azure subscription and a user account with the Owner or Contributor role in that subscription.

## Exercise 1: Authoring ARM templates for Azure VM deployment

### Scenario

To streamline Azure-based operations, you decide to develop and implement an automated deployment and configuration process for Windows Server to Azure VMs. Your deployments need to comply with the Information Security team's requirements and adhere to Contoso, Ltd.'s intended target operational model, including high availability.

The main tasks for this exercise are as follows:

1. Connect to your Azure subscription and enable enhanced security of Microsoft Defender for Cloud.
1. Generate an ARM template and parameters files by using the Azure portal.
1. Download the ARM template and parameters files from the Azure portal.

#### Task 1: Connect to your Azure subscription and enable enhanced security of Microsoft Defender for Cloud

In this task, you will connect to your Azure subscription and enable the enhanced security features of Microsoft Defender for Cloud.

1. Connect to **SEA-ADM1**, and then, if needed, sign in as **CONTOSO\\Administrator** with a password of **Pa55w.rd**.
1. On **SEA-ADM1**, start Microsoft Edge, go to the [Azure portal](https://portal.azure.com), and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.

>**Note**: Skip the remaining steps in this task and proceed directly to the next one if you have already enabled Microsoft Defender for Cloud in your Azure subscription.

1. In the Azure portal, browse to the **Microsoft Defender for Cloud** page.
1. From the **Microsoft Defender for Cloud \| Getting started** page, enable enhanced security of Microsoft Defender for Cloud and enable automatic Microsoft Defender for Cloud agent installation.

#### Task 2: Generate an ARM template and parameters files by using the Azure portal

1. From the Azure portal, step through the process of creating a new Azure VM using the following settings (leaving all others with their default values), but do not deploy it:

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you will be using in this lab.|
   |Resource group|the name of a new resource group **AZ800-L0601-RG**|
   |Virtual machine name|**az800l06-vm0**|
   |Region|Use the name of an Azure region in which you can provision Azure virtual machines|
   |Availability options|No infrastructure redundancy required|
   |Image|**Windows Server 2022 Datacenter: Azure Edition - Gen2**|
   |Azure Spot instance|No|
   |Size|**Standard_D2s_v3**|
   |Username|**Student**|
   |Password|**Pa55w.rd1234**|
   |Public inbound ports|None|
   |Would you like to use an existing Windows Server license|No|
   |OS disk type|**Standard HDD**|
   |Name|**az800l06-vnet**|
   |Address range|**10.60.0.0/20**|
   |Subnet name|**subnet0**|
   |Subnet range|**10.60.0.0/24**|
   |Public IP|None|
   |NIC network security group|None|
   |Accelerated networking|Off|
   |Place this virtual machine behind an existing load balancing solution?|No|
   |Boot diagnostics|**Enable with managed storage account (recommended)**|

1. When you reach the **Review + Create** tab of the **Create a virtual machine** page, proceed to task 3.

   >**Note**: Do not create the virtual machine. You will use for this purpose the autogenerated template.

#### Task 3: Download the ARM template and parameters files from the Azure portal

1. From the **Review + Create** tab of the **Create a virtual machine** page, download the template for automation and copy it to the **C:\\Labfiles\\Mod06** folder on the lab VM.
1. In the Azure portal, close the **Create a virtual machine** page.

## Exercise 2: Modifying ARM templates to include VM extension-based configuration

### Scenario

In addition to automated Azure resources deployments, you also want to ensure that you can automatically configure Windows Server running in Azure VMs. To accomplish this, you want to test the use of Azure Custom Script Extension.

The main tasks for this exercise are as follows:

1. Review the ARM template and parameters files for Azure VM deployment.
1. Add an Azure VM extension section to the existing template.

#### Task 1: Review the ARM template and parameters files for Azure VM deployment

1. Extract the contents of the downloaded archive into the **C:\\Labfiles\\Mod06** folder.
1. Open the **template.json** file in Notepad and review the contents. Keep the Notepad window open.
1. Open the **C:\\Labfiles\\Mod06\\parameters.json** file in Notepad, review it, and close the Notepad window.

#### Task 2: Add an Azure VM extension section to the existing template

1. On the lab VM, in the Notepad window displaying the contents of the **template.json** file, insert the following code directly underneath the `    "resources": [` line):

   >**Note**: If you are using a tool that pastes the code in line by line, intellisense may add extra brackets causing validation errors. You may want to paste the code into notepad first and then paste it into the JSON file.

   ```json
        {
           "type": "Microsoft.Compute/virtualMachines/extensions",
           "name": "[concat(parameters('virtualMachineName'), '/customScriptExtension')]",
           "apiVersion": "2018-06-01",
           "location": "[resourceGroup().location]",
           "dependsOn": [
               "[concat('Microsoft.Compute/virtualMachines/', parameters('virtualMachineName'))]"
           ],
           "properties": {
               "publisher": "Microsoft.Compute",
               "type": "CustomScriptExtension",
               "typeHandlerVersion": "1.7",
               "autoUpgradeMinorVersion": true,
               "settings": {
                   "commandToExecute": "powershell.exe Install-WindowsFeature -name Web-Server -IncludeManagementTools && powershell.exe remove-item 'C:\\inetpub\\wwwroot\\iisstart.htm' && powershell.exe Add-Content -Path 'C:\\inetpub\\wwwroot\\iisstart.htm' -Value $('Hello World from ' + $env:computername)"
              }
           }
        },
   ```
1. Save the change and close the file.

## Exercise 3: Deploying Azure VMs running Windows Server by using ARM templates

### Scenario

With the ARM templates configured, you will verify their functionality by performing a deployment into your proof-of-concept Azure subscription.

The main tasks for this exercise are as follows:

1. Deploy an Azure VM by using an ARM template.
1. Review results of the Azure VM deployment.

#### Task 1: Deploy an Azure VM by using an ARM template

1. On **SEA-ADM1**, in the Azure portal, browse to the **Custom deployment** page, and then select the option to **Build your own template in the editor**.
1. Load the template file and the parameter file into the **Custom deployment** page.
1. Deploy the template with the following settings, leaving all other settings with their default values:

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Resource group|**AZ800-L0601-RG**|
   |Region|the name of the Azure region into which you can provision Azure VMs|
   |Admin Password|**Pa55w.rd1234**|

   >**Note**: The deployment might take about 10 minutes.

1. Verify that the deployment completed successfully.

#### Task 2: Review results of the Azure VM deployment

1. In the Azure portal, browse to the **AZ800-L0601-RG** resource group page and review the list of its resources, particularly the Azure VM **az800l06-vm0**.
1. Browse to the **az800l06-vm0** Azure VM page and verify that the **customScriptExtension** has been provisioned successfully.
1. Browse back to the **AZ800-L0601-RG** resource group page, review its deployments, and review the **Microsoft.Template** that was used to deploy it to confirm that it matches the template you used for deployment.

## Exercise 4: Configuring administrative access to Azure VMs running Windows Server

### Scenario

With the Azure VMs running Windows Server in place, you want to test the ability to manage them remotely from your on-premises administrative workstation.

The main tasks for this exercise are as follows:

1. Verify the status of Azure Microsoft Defender for Cloud.
1. Review Just in time VM access settings.

#### Task 1: Verify the status of Azure Microsoft Defender for Cloud

1. In the Azure portal, browse to the **Microsoft Defender for Cloud** page.
1. Verify that the enhanced security features of Microsoft Defender for Cloud are enabled.

#### Task 2: Review the Just-in-time VM access settings

1. In the Azure portal, browse to the **Microsoft Defender for Cloud \| Workload protections** page and review **Just in time VM access** settings.
1. On the **Just-in-time VM access** page, review the **Configured**, **Not Configured**, and **Unsupported** tabs.

   >**Note**: It might take up to 24 hours for the newly deployed VM to appear in the **Unsupported** tab. Rather than wait, continue to the next exercise.

## Exercise 5: Configuring Windows Server security in Azure VMs

### Scenario

With the Azure VMs running Windows Server in place, you want to test the ability to manage them remotely from your on-premises administrative workstation.

The main tasks for this exercise are as follows:

1. Create and configure an NSG.
1. Configure inbound HTTP access to an Azure VM.
1. Trigger re-evaluation of the JIT status of an Azure VM.
1. Connect to the Azure VM via JIT VM access.

#### Task 1: Create and configure an NSG

1. In the Azure portal, create an NSG with the following settings, leaving all other settings with their default values:

   |Setting|Value|
   |---|---|
   |Subscription|the name of the Azure subscription you are using in this lab|
   |Resource group|**AZ800-L0601-RG**|
   |Name|**az800l06-vm0-nsg1**|
   |Region|the name of the Azure region into which you provisioned the Azure VM **az800l06-vm0**|

1. Add an inbound security rule to the newly created network security group with the following settings, leaving all other settings with their default values:

   |Setting|Value|
   |---|---|
   |Source|**Any**|
   |Source port ranges|*|
   |Destination|**Any**|
   |Service|**HTTP**|
   |Action|**Allow**|
   |Priority|**300**|
   |Name|**AllowHTTPInBound**|

#### Task 2: Configure inbound HTTP access to an Azure VM

1. In the Azure portal, browse to the page of the network interface attached to the **az800l06-vm0** Azure VM, and associate it with the network security group you created in the previous task.
1. In the Azure portal, browse to the IP configuration of the network interface attached to the **az800l06-vm0** Azure VM, and associate it with a new, public IP address with the following settings, leaving all others with their default values:

   |Setting|Value|
   |---|---|
   |Name|**az800l06-vm0-pip1**|
   |SKU|**Standard**|

1. From the lab VM, open a browser tab, browse to the newly created public IP address, and verify that the page displays the message, **Hello World from az800l06-vm0**.
1. From the lab VM, try to establish a Remote Desktop connection to the same IP address and verify that the connection attempt fails.

   >**Note**: This is expected because the Azure VM is currently not accessible from the Internet via TCP port 3389. It is accessible only via TCP port 80.

#### Task 3: Trigger re-evaluation of the JIT status of an Azure VM

>**Note**: This task is necessary to trigger a re-evaluation of the JIT status of the Azure VM. By default, this might take up to 24 hours.

1. In the Azure portal, browse back to the **az800l06-vm0** page.
1. On the **az800l06-vm0** page, select **Configuration**. 
1. On the **az800l06-vm0 \| Configuration** page, select **Enable just-in-time** VM access and select the **Open Microsoft Defender for Cloud** link.
1. On the **Just-in-time VM access** page, verify that the entry representing the **az800l06-vm0** Azure VM appears on the **Configured** tab.

#### Task 4: Connect to the Azure VM via JIT VM access

1. From the **az800l06-vm0** page in the Azure portal, request JIT VM access.
1. When the request is approved, initiate a Remote Desktop session to the target Azure VM.
1. When prompted for credentials, specify the following values:
   
   |Setting|Value|
   |---|---|
   |Username|**Student**|
   |Password|**Pa55w.rd1234**|

1. Verify that you can successfully access via Remote Desktop the operating system running in the Azure VM and close the Remote Desktop session.

## Exercise 6: Deprovisioning the Azure environment

### Scenario

To minimize Azure-related charges, you want to deprovision the Azure resources provisioned throughout this lab.

The main tasks for this exercise are as follows:

1. Start a PowerShell session in Cloud Shell.
1. Identify all Azure resources provisioned in the lab.

#### Task 1: Start a PowerShell session in Cloud Shell

1. From the Azure portal, open a PowerShell session in the Azure Cloud Shell pane.
1. If this is the first time you're starting **Cloud Shell**, accept the default settings.

#### Task 2: Identify all Azure resources provisioned in the lab

1. From the Cloud Shell pane, run the following command to list all resource groups created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ800-L06*'
   ```
1. Run the following command to delete all resource groups created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ800-L06*' | Remove-AzResourceGroup -Force -AsJob
   ```

## Results

After completing this lab, you will have deployed and configured Azure VMs running Windows Server in the manner that satisfies the Contoso, Ltd. manageability and security requirements.
