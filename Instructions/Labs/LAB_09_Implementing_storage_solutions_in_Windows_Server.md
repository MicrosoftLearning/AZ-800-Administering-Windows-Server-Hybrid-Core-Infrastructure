---
lab:
    title: 'Lab: Implementing storage solutions in Windows Server'
    module: 'Module 9: File servers and storage management in Windows Server'
---

# Lab: Implementing storage solutions in Windows Server

## Scenario

At Contoso, Ltd., you need to implement the Storage Spaces feature on the Windows Server servers to simplify storage access and provide redundancy at the storage level. Management wants you to test Data Deduplication to save storage. They also want you to implement Internet Small Computer System Interface (iSCSI) storage to provide a simpler solution for deploying storage in the organization. Additionally, the organization is exploring options for making storage highly available and researching the requirements that it must meet for high availability. You want to test the feasibility of using highly available storage, specifically Storage Spaces Direct.

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-800%20Lab%20Simulation%20-%20Implementing%20storage%20solutions%20in%20Windows%20Server)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Objectives

After completing this lab, you'll be able to:

- Implement Data Deduplication.
- Configure iSCSI storage.
- Configure Storage Spaces.
- Implement Storage Spaces Direct.

## Estimated time: 90 minutes

## Lab setup

Virtual machines: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, **AZ-800T00A-SEA-SVR2**, **AZ-800T00A-SEA-SVR3**, and **AZ-800T00A-ADM1** must be running. 

- For Exercises 1-3: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR3**, and **AZ-800T00A-SEA-ADM1**
- For Exercise 4: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, **AZ-800T00A-SEA-SVR2**, **AZ-800T00A-SEA-SVR3**, and **AZ-800T00A-SEA-ADM1**

> **Note**: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, **AZ-800T00A-SEA-SVR2**, **AZ-800T00A-SEA-SVR3**, and **AZ-800T00A-SEA-ADM1** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, **SEA-SVR2**, **SEA-SVR3**, and **SEA-ADM1**, respectively.

1. Select **SEA-ADM1**.
1. Sign in using the credentials provided by the instructor.

For this lab, you'll use the available VM environment.

## Lab exercise 1: Implementing Data Deduplication

### Scenario

You decide to install the Data Deduplication role service by using Server Manager. You determine that drive **M** is heavily used, and you suspect that it contains duplicate files in some folders. You decide to enable and configure the Data Deduplication role to reduce the consumed space on this volume.

The main tasks for this exercise are as follows:

1. Install the Data Deduplication feature on **SEA-SVR3**.
1. Enable and configure Data Deduplication on drive **M** on **SEA-SVR3**.
1. Test Data Deduplication by adding files and observing deduplication.

#### Task 1: Install the Data Deduplication role service

1. On **SEA-ADM1**, use **Server Manager** to install the Data Deduplication role service on **SEA-SVR3**.
1. On **SEA-ADM1**, share the **C:\Labfiles** folder with the **Read** permissions granted to the **Users** group.
1. Switch to the **SEA-SVR3** console session, and then, if needed, sign in with the credentials provided by the instructor.
1. On **SEA-SVR3**, start a **Windows PowerShell** session, and then, in the **Windows PowerShell** console, run the following commands to create a volume formatted with ReFS and with the drive letter **M** assigned to it:

   ```powershell
   Get-Disk
   Initialize-Disk -Number 1
   New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter M
   Format-Volume -DriveLetter M -FileSystem ReFS
   ```
1. On **SEA-SVR3**, in the **Windows PowerShell** console, run the following commands to copy from **SEA-ADM1** a script that creates sample files to be deduplicated, execute it, and identify the outcome:

   ```powershell
   New-PSDrive –Name 'X' –PSProvider FileSystem –Root '\\SEA-ADM1\Labfiles'
   New-Item -Type Directory -Path 'M:\Data' -Force
   Copy-Item -Path X:\Lab09\CreateLabFiles.cmd -Destination M:\Data\ -PassThru
   Start-Process -FilePath M:\Data\CreateLabFiles.cmd -PassThru
   Set-Location -Path M:\Data
   Get-ChildItem -Path .
   Get-PSDrive -Name M
   ```

   > **Note**: Record the free space on drive **M**.

#### Task 2: Enable and configure Data Deduplication

1. Switch back to the console session to **SEA-ADM1**.
1. Use the **File and Storage Services** interface in **Server Manager** to display disks on **SEA-SVR3**.
1. Enable Data Deduplication on the **M** volume on disk number **1** on **SEA-SVR3** with the following settings:

   - Deduplication option: **General purpose file server**
   - Deduplicate files older than (in days): **0**
   - Enable throughput optimization: Selected

#### Task 3: Test Data Deduplication

1. On **SEA-ADM1**, start **Windows PowerShell** as Administrator.

   >**Note**: Perform the next two steps in case you have not already installed Windows Admin Center on **SEA-ADM1**.

1. In the **Windows PowerShell** console, run the following command to download the latest version of Windows Admin Center:
	
   ```powershell
   Start-BitsTransfer -Source https://aka.ms/WACDownload -Destination "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"
   ```
1. Run the following command to install Windows Admin Center:
	
   ```powershell
   Start-Process msiexec.exe -Wait -ArgumentList "/i $env:USERPROFILE\Downloads\WindowsAdminCenter.msi /qn /L*v log.txt REGISTRY_REDIRECT_PORT_80=1 SME_PORT=443 SSL_CERTIFICATE_OPTION=generate"
   ```

   > **Note**: Wait until the installation completes. This should take about 2 minutes.

1. On **SEA-ADM1**, start Microsoft Edge and connect to the local instance of Windows Admin Center at `https://SEA-ADM1.contoso.com`. 
1. If prompted, in the **Windows Security** dialog box, enter the credentials provided by the instructor, and then select **OK**.

1. In Windows Admin Center, add a connection to **sea-svr3.contoso.com** and connect to it with the credentials provided by the instructor.
1. While connected to **sea-svr3.contoso.com**, in the **Tools** list, use the **PowerShell** tool to run the following command which triggers deduplication:

   ```powershell
   Start-DedupJob -Volume M: -Type Optimization –Memory 50
   ```
1. Switch back to the console session to **SEA-SVR3**.
1. On **SEA-SVR3**, at the **Windows PowerShell** prompt, run the following command to identify the available space on the volume being deduplicated:

   ```powershell
   Get-PSDrive -Name M
   ```

   > **Note**: Compare the previously displayed values with the current ones. 

1. Wait for five to ten minutes to allow the deduplication job to complete and repeat the previous step.
1. Switch back to the console session to **SEA-ADM1**.
1. On **SEA-ADM1**, in Windows Admin Center connected to **sea-svr3.contoso.com**, use the **PowerShell** tool to run the following commands that identify the status of the deduplication job:

   ```powershell
   Get-DedupStatus –Volume M: | fl
   Get-DedupVolume –Volume M: |fl
   Get-DedupMetadata –Volume M: |fl
   ```
1. On **SEA-ADM1**, refresh the Disks pane in **Server Manager** and display the properties of the **M:** volume.
1. In the **Volume (M:\\) Properties** window, review the values for **Deduplication rate** and **Deduplication savings**.

## Lab exercise 2: Configuring iSCSI storage

### Scenario

Executives at Contoso are exploring the option of using iSCSI to decrease the cost and complexity of configuring centralized storage. To test this, you must install and configure the iSCSI targets, and configure the iSCSI initiators to provide access to the targets.

The main tasks for this exercise are as follows:

1. Install iSCSI and configure targets on **SEA-SVR3**.
1. Connect to and configure iSCSI targets from **SEA-DC1** (initiator).
1. Verify iSCSI disk configuration.
1. Revert disk configuration.

#### Task 1: Install iSCSI and configure targets

1. On **SEA-ADM1**, in the **Windows PowerShell** console, run the following command to establish a PowerShell Remoting session to **SEA-SVR3**:

   ```powershell
   Enter-PSSession -ComputerName SEA-SVR3
   ```
1. Run the following command to install iSCSI target on **SEA-SVR3**:

   ```powershell
   Install-WindowsFeature –Name FS-iSCSITarget-Server –IncludeManagementTools
   ```
1. Run the following commands to create a new volume formatted with ReFS on disk 2:

   ```powershell
   Initialize-Disk -Number 2
   $partition2 = New-Partition -DiskNumber 2 -UseMaximumSize -AssignDriveLetter
   Format-Volume -DriveLetter $partition2.DriveLetter -FileSystem ReFS
   ```
1. Run the following commands to create a new volume formatted with ReFS on disk 3:

   ```powershell
   Initialize-Disk -Number 3
   $partition3 = New-Partition -DiskNumber 3 -UseMaximumSize -AssignDriveLetter
   Format-Volume -DriveLetter $partition3.DriveLetter -FileSystem ReFS
   ```
1. Run the following commands to configure Windows Defender Firewall with Advanced Security rules that allow iSCSI traffic:

   ```powershell
   New-NetFirewallRule -DisplayName "iSCSITargetIn" -Profile "Any" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3260
   New-NetFirewallRule -DisplayName "iSCSITargetOut" -Profile "Any" -Direction Outbound -Action Allow -Protocol TCP -LocalPort 3260
   ```
1. Run the following commands to display the drive letters assigned to the newly created volumes:

   ```powershell
   $partition2.DriveLetter
   $partition3.DriveLetter
   ```

   > **Note**: The instructions assume that drive letters are **E** and **F** respectively. If your drive letter assignments are different, take this into account as you follow instructions in this exercise.

#### Task 2: Connect to and configure iSCSI targets

1. On **SEA-ADM1**, refresh the Disks pane in **Server Manager** and display the disk configuration of **SEA-DC1**. Note that it only contains the boot and system volume drive **C**.
1. In **Server Manager**, in **File and Storage Services**, switch to the iSCSI pane. 
1. From the iSCSI pane, create an iSCSI virtual disk with the following settings:

   - Storage Location: **E:**
   - Name: **iSCSIDisk1**
   - Disk size: **5 GB**, **Dynamically Expanding**
   - iSCSI target: **New**
   - Target name: **iSCSIFarm**
   - Access servers: **SEA-DC1**

1. Create a second iSCSI virtual disk with the following settings:

   - Storage Location: **F:**
   - Name: **iSCSIDisk2**
   - Disk size: **5 GB**, **Dynamically Expanding**
   - iSCSI target: **iSCSIFarm**

1. Switch to the **SEA-DC1** console session, and then, if needed, sign in with the credentials provided by the instructor.
1. On **SEA-SVR3**, start a **Windows PowerShell** session, and then, in the **Windows PowerShell** console, run the following commands to start the iSCSI Initiator service and display the iSCSI Initiator configuration:

   ```powershell
   Start-Service msiscsi
   iscsicpl
   ```

   > **Note**: The **iscsicpl** command will open an **iSCSI Initiator Properties** window.

1. Use the **iSCSI Initiator Properties** interface to connect to the following iSCSI target:

   - Name: **SEA-SVR3**
   - Target name: **iqn.1991-05.com.microsoft:SEA-SVR3-fileserver-target**

#### Task 3: Verify iSCSI disk configuration 

1. Switch back to the console session to **SEA-ADM1**.
1. In **Server Manager**, browse to the Disks pane of **File and Storage Services** and refresh its view. 
1. Review the **SEA-DC1** disk configuration and verify that it includes two **5 GB** disks with the **Offline** status and the **iSCSI** bus type.
1. Switch to the **SEA-DC1** console session. 
1. At the **Windows PowerShell** prompt, run the following command to display the disk configuration:

   ```powershell
   Get-Disk
   ```
   > **Note**: Both disks are present and healthy, but offline. To use them, you need to initialize and format them.

1. On **SEA-DC1**, from the **Windows PowerShell** prompt, run the following commands to create a volume formatted with ReFS with the drive letter **E**.

   ```powershell
   Initialize-Disk -Number 1
   New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter E
   Format-Volume -DriveLetter E -FileSystem ReFS
   ```
1. Repeat the previous step to create a new drive formatted with ReFS, but this time, use the disk number **2** and the drive letter **F**.
1. Switch back to the console session to **SEA-ADM1**, with the **Server Manager** window active.
1. In **Server Manager**, refresh the Disks pane in **File and Storage Services**.
1. Review the **SEA-DC1** disk configuration and verify that both drives are now **Online**.

#### Task 4: Revert disk configuration 

1. Switch back to the console session to **SEA-SVR3**.
1. At the **Windows PowerShell** prompt, run the following commands to reset disks on **SEA-SVR3** to their original state:

   ```powershell
   for ($num = 1;$num -le 4; $num++) {Clear-Disk -Number $num -RemoveData -RemoveOEM -ErrorAction SilentlyContinue}
   for ($num = 1;$num -le 4; $num++) {Set-Disk -Number $num -IsOffline $true}
   ```

   > **Note**: This is necessary in order to prepare for the next exercise.

## Lab exercise 3: Configuring redundant Storage Spaces

### Scenario

To meet some requirements for high availability, you decide to evaluate redundancy options in Storage Spaces. Additionally, you want to test the provisioning of new disks to the storage pool.

The main tasks for this exercise are as follows:

1. Create a storage pool.
1. Create a volume based on a three-way mirrored disk.
1. Manage a volume in File Explorer.
1. Disconnect a disk from the storage pool and verify volume availability.
1. Add a disk to the storage pool and verify volume availability.
1. Revert disk configuration.

> **Note:** In Windows Server, you can't disconnect a disk in a storage pool. You can only remove it. You also can't remove a disk from a three-way mirror without adding a new disk first. 

#### Task 1: Create a storage pool 

1. Switch to **SEA-ADM1** and refresh the Disks pane of **File and Storage Services** in **Server Manager**.
1. Set the status of the disks 1-4 of **SEA-SVR3** to **Online**.
1. In **Server Manager** targeting storage configuration of **SEA-SVR3**, create a new storage pool named **SP1** consisting of the three disks of **127 GB** in size.

#### Task 2: Create a volume based on a three-way mirrored disk 

1. On **SEA-ADM1**, from **Server Manager**, use the newly created storage pool **SP1** to create a virtual disk named **Three-Mirror** that uses the mirror storage layout, thin provisioning, and has the size of **25 GB**.
1. Use the newly provisioned virtual disk to create an ReFS volume named **TestData**, set its size to all available disk space, and assign to it drive letter **T**.

#### Task 3: Manage a volume in File Explorer 

1. On **SEA-ADM1**, switch to the **Windows PowerShell** hosting PowerShell Remoting session to **SEA-SVR3**.
1. Use the PowerShell Remoting session to enable all of the File and Printer Sharing rules of Windows Defender Firewall with Advanced Security by running the following command:

   ```
   Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28502"
   ```

1. On **SEA-ADM1**, start **File Explorer** and browse to the **\\\\SEA-SVR3.contoso.com\\t$** share.
1. Create a folder named **TestData**, and then, within the folder, create a document named **TestDocument.txt**.

#### Task 4: Disconnect a disk from the storage pool and verify volume availability 

1. On **SEA-ADM1**, use **Server Manager** to add the remaining available disk attached to **SEA-SVR3** to the storage pool **SP1**. Ensure the disk uses automatic allocation.
1. Use **Server Manager** to remove one of the first three disks allocated to the **SP1** pool.
1. On **SEA-ADM1**, use File Explorer to verify that **TestDocument.txt** is still available. 

#### Task 5: Add a disk to the storage pool and verify volume availability 

1. On **SEA-ADM1**, in **Server Manager**, re-scan the **SP1** storage pool.
1. Add back the disk you removed in the previous task and ensure that it uses automatic allocation.
1. On **SEA-ADM1**, use File Explorer to verify that **TestDocument.txt** is still available. 
1. Switch back to **SEA-SVR3**.

#### Task 6: Revert disk configuration 

1. Switch back to the console session to **SEA-SVR3**.
1. At the **Windows PowerShell** prompt, run the following commands to reset disks on **SEA-SVR3** to their original state:

   ```powershell
   Get-VirtualDisk -FriendlyName 'Three-Mirror' | Remove-VirtualDisk
   Get-StoragePool -FriendlyName 'SP1' | Remove-StoragePool
   for ($num = 1;$num -le 4; $num++) {Clear-Disk -Number $num -RemoveData -RemoveOEM -ErrorAction SilentlyContinue}
   for ($num = 1;$num -le 4; $num++) {Set-Disk -Number $num -IsOffline $true}
   ```

   > **Note**: This is necessary to prepare for the next exercise.

## Lab exercise 4: Implementing Storage Spaces Direct

### Scenario

You want to test whether using local storage as highly available storage is a viable solution for your organization. Previously, your organization has only used storage area networks (SANs) for storing VMs. The features in Windows Server make it possible to use only local storage, so you want to implement Storage Spaces Direct as a test implementation.

The main tasks for this exercise are as follows:

1. Prepare for installation of Storage Spaces Direct.
1. Create and validate the failover cluster.
1. Enable Storage Spaces Direct.
1. Create a storage pool, a virtual disk, and a share.
1. Verify Storage Spaces Direct functionality.

#### Task 1: Prepare for installation of Storage Spaces Direct 

1. On **SEA-ADM1**, in **Server Manager**, verify that **SEA-SVR1**, **SEA-SVR2**, and **SEA-SVR3** have the **Manageability** status of **Online – Performance counters not started** before continuing.
1. In **Server Manager**, browse to the Disks pane of **File and Storage Services**.
1. On the Disks pane, browse to the **SEA-SVR3** node and verify that disks 1 through 4 are listed as **Unknown**.
1. Within the Disks pane of **Server Manager**, bring online all of the disks attached to **SEA-SVR1**, **SEA-SVR2**, and **SEA-SVR3**.
1. On **SEA-ADM1**, start **Windows PowerShell ISE** and open **C:\\Labfiles\\Lab09\\Implement-StorageSpacesDirect.ps1** in its script pane.

   > **Note**: The script is divided into numbered steps. There are eight steps, and each step has a number of commands. To execute an individual line, you can place the cursor anywhere within that line and press F8 or select the **Run Selection** in the toolbar of the **Windows PowerShell ISE** window. To execute multiple lines, select all of them in their entirety, and then use either F8 or the **Run Selection** toolbar icon. The sequence of steps is described in the instructions of this exercise. Ensure that each step completes before starting the next one.

1. Run the first command in step 1 to install File Server role and Failover Clustering feature on **SEA-SVR1**, **SEA-SVR2**, and **SEA-SVR3**.

   > **Note**: Wait until the installation finishes. This should take about 2 minutes. Verify that, in the output of each command, the **Success** property is set to **True**.

1. Run the second command in step 1 to restart **SEA-SVR1**, **SEA-SVR2**, and **SEA-SVR3**.

   > **Note**: After you invoke the second command to restart the servers, you can run the third command to install the Failover Clustering management tools without waiting for the restarts to finish.

1. Run the third command in step 1 to install **Failover Cluster Manager** tool on **SEA-ADM1**.

   > **Note**: Wait a few minutes while the servers restart and the **Failover Cluster Manager** tool is installed on **SEA-ADM1**.

#### Task 2: Create and validate the failover cluster 

1. On **SEA-ADM1**, start the **Failover Cluster Manager** console.
1. On **SEA-ADM1**, in **Windows PowerShell ISE**, run the step 2 command to invoke cluster validation tests.

   > **Note**: Wait until the tests complete. This should take about 2 minutes. Verify that none of the tests fail. Ignore any warnings since these are expected.

1. In **Windows PowerShell ISE**, run the step 3 command to create a cluster.

   > **Note**: Wait until the step completes. This should take about 2 minutes. 

1. When the command completes, switch to **Failover Cluster Manager** and add the newly created cluster named **S2DCluster.Contoso.com**.

#### Task 3: Enable Storage Spaces Direct

1. On **SEA-ADM1**, in **Windows PowerShell ISE**, run the step 4 command to enable Storage Spaces Direct on the newly installed cluster.

   > **Note**: Wait until the step completes. This should take about 1 minute.

1. In **Windows PowerShell ISE**, run the step 5 command to create the storage pool named **S2DStoragePool**.

   > **Note**: Wait until the step completes. This should take less than 1 minute. In the output of the command, verify that the **FriendlyName** attribute has a value of **S2DStoragePool**.

1. Switch to the **Failover Cluster Manager** and verify that the cluster contains the storage pool named **Cluster Pool 1**.
1. Switch to **Windows PowerShell ISE**, and run the step 6 command to create virtual disks.

   > **Note**: Wait until the step completes. This should take less than 1 minute. 

1. Switch to the **Failover Cluster Manager** and verify that the **Cluster Virtual Disk (CSV)** object appears in Disks pane.

#### Task 4: Create a storage pool, a virtual disk, and a share

1. On **SEA-ADM1**, in **Windows PowerShell ISE**, run the step 7 command to create the S2D-SOFS role.

   > **Note**: Wait until the step completes. This should take less than 1 minute. 

1. Switch to **Failover Cluster Manager** and verify that the **S2D-SOFS** object appears in the Roles pane.
1. Switch to **Windows PowerShell ISE** and run all three commands in Step 8 to create the **VM01** share. 
1. Switch to **Failover Cluster Manager** and verify that the **VM01** share appears in the Shares pane.

#### Task 5: Verify Storage Spaces Direct functionality

1. On **SEA-ADM1**, in File Explorer, open the **\\\\s2d-sofs\\VM01** share and create a folder named **VMFolder**.
1. On **SEA-ADM1**, from the console pane of **Windows PowerShell ISE**, run the following command to shut down **SEA-SVR3**:

   ```powershell
   Stop-Computer -ComputerName SEA-SVR3 -Force
   ```
1. Switch to **Server Manager**, refresh the **All Servers** view, and verify that **SEA-SVR3** is no longer accessible.
1. Switch to the **Failover Cluster Manager** and review the **Cluster Virtual Disk (CSV)** information in the **Disks** node. 
1. Verify that for the **Cluster Virtual Disk (CSV)**, the **Health Status** is set to **Warning** and **Operational Status** to **Degraded** (**Operational Status** might also be listed as **Incomplete**.)
1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying Windows Admin Center. 
1. In Windows Admin Center, add a connection to the **S2DCluster.Contoso.com** cluster. 

   > **Note**: Don't add the cluster nodes since they are already available in Windows Admin Center. 

1. In Windows Admin Center, on the cluster's Dashboard pane, identify the alert indicating that **SEA-SVR3** is not reachable. 
1. Switch to the console session to **SEA-SVR3** and start it. 
1. Verify that the alert is automatically removed after a few minutes.
1. Refresh the browser page displaying Windows Admin Center and verify that all servers are healthy.

### Results

After completing this lab, you will have:

- Tested the implementation of Data Deduplication.
- Installed and configured iSCSI storage.
- Configured redundant Storage Spaces.
- Tested the implementation of Storage Spaces Direct.
