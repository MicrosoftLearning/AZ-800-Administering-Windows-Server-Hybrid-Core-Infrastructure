---
lab:
    title: 'Lab: Implementing Azure File Sync'
    module: 'Module 10: Implementing a hybrid file server infrastructure'
---

# Lab: Implementing Azure File Sync

## Scenario

To address concerns regarding Distributed File System (DFS) Replication between Contoso's London headquarters and its Seattle–based branch office, you decide to test Azure File Sync as an alternative replication mechanism between two on-premises file shares.

## Objectives

After completing this lab, you'll be able to:

- Implement DFS Replication in your on-premises environment.
- Create and configure a sync group.
- Replace DFS Replication with Azure File Sync-based replication.
- Verify replication and enable cloud tiering.
- Troubleshoot replication conflicts.

## Estimated time: 60 minutes

## Lab setup

Virtual machines: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, **AZ-800T00A-SEA-SVR2**, and **AZ-800T00A-ADM1** must be running. 

> **Note**: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, **AZ-800T00A-SEA-SVR2**, and **AZ-800T00A-SEA-ADM1** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, **SEA-SVR2**, and **SEA-ADM1**, respectively.

1. Select **SEA-ADM1**.
1. Sign in using the following credentials:

   - User name: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment and an Azure subscription. Before you begin the lab, ensure that you have an Azure subscription and a user account with the Owner or Contributor role in that subscription.

## Exercise 1: Implementing DFS Replication in your on-premises environment

### Scenario

Exercise scenario: Before you start testing an on-premises DFS Replication migration, you first need to implement DFS Replication in your proof-of-concept environment on **SEA-SVR1** and **SEA-SVR2**.

The main tasks for this exercise are:

1. Deploy DFS.
1. Test DFS deployment.

#### Task 1: Deploy DFS

1. On **SEA-ADM1**, start Windows PowerShell as Administrator and install Distributed File System (DFS) management tools by running the following command:

   ```powershell
   Install-WindowsFeature -Name RSAT-DFS-Mgmt-Con -IncludeManagementTools
   ```
1. On **SEA-ADM1**, open File Explorer, browse to the **C:\\Labfiles\\Lab10** folder, and open **L10-DeployDFS.ps1** in the script pane of a new **Windows PowerShell ISE** window.
1. In the script pane, review the script and then execute it to create a sample DFS namespace and a DFS replication group.

#### Task 2: Test DFS deployment

1. On **SEA-ADM1**, start the **DFS Management** console and add to it both the **\\\\Contoso.com\\Root\\** namespace and the **Branch1** replication group you created in the previous task. 
1. Verify that the **\\\\Contoso.com\\Root\\Data** folder has targets on **SEA-SVR1** and **SEA-SVR2**. Note the folders configured as the targets.
1. Verify that the **Branch1** replication group has two members, **SEA-SVR1** and **SEA-SVR2**. Note the folders replicated on each server.
1. Open two instances of File Explorer. In the first instance, connect to **\\\\SEA-SVR1\\Data**, and then in the second instance, connect to **\\\\SEA-SVR2\\Data**.
1. Create a new file with your name in **\\\\SEA-SVR1\\Data**, and then confirm that the file replicates to **\\\\SEA-SVR2\\Data** after a few seconds. This confirms that DFS Replication is working.

   >**Note:** Wait until the files are replicated and both File Explorer windows record the same content.

### Results

After completing this exercise, you'll have created a working DFS infrastructure. This includes DFS Replication, which replicates content between **SEA-SVR1** and **SEA-SVR2**.

## Exercise 2: Creating and configuring a sync group

### Scenario

To prepare for migrating the DFS Replication environment to File Sync, you must first create and configure a File Sync group.

The main tasks for this exercise are:

1. Create an Azure file share.
1. Use an Azure file share.
1. Deploy Storage Sync Service and a File Sync group.

#### Task 1: Create an Azure file share

1. On **SEA-ADM1**, start Microsoft Edge, browse to the Azure portal, and then authenticate with your Azure credentials.
1. In the Azure portal, create an Azure storage account with **Locally-redundant storage (LRS)** in a resource group named **AZ800-L1001-RG**.

   >**Note:** Use the same region for deploying all Azure resources in this lab.

1. In the storage account, create a file share named **share1**.

#### Task 2: Use an Azure file share

1. On **SEA-ADM1**, upload the **C:\\Labfiles\\Lab10\\File1.txt** file to **share1**.
1. In the Azure portal, create a snapshot of **share1**.
1. On **SEA-ADM1**, mount **share1** as the drive **Z** by using the connection script that the Azure portal provides.
1. In File Explorer, on the mounted drive, open the file named **File1.txt**, enter your name, and then save the file.
1. Use **Previous Versions** in File Explorer to restore the previous version of **File1.txt**.
1. Open **File1.txt**, and then verify that it doesn't include your name.

#### Task 3: Deploy Storage Sync Service and a File Sync group

1. On **SEA-ADM1**, use the Azure portal to create an Azure File Sync resource named **FileSync1**. Use the same region and Resource Group as you used when deploying the storage account.

   >**Note:** Deploying File Sync creates a Storage Sync Service resource.

1. Create a sync group named **Sync1** in the **FileSync1** Storage Sync Service. Use the storage account that you created earlier and **share1** as the Azure file share when creating **Sync1**.
1. Verify that no server is currently registered with **FileSync1**.

### Results

After completing this exercise, you will have created a File Sync group. You also have created the cloud endpoint mapped on **SEA-ADM1** so that you can inspect the Azure file share content.

## Exercise 3: Replacing DFS Replication with File Sync-based replication

### Scenario

Now that you have all the necessary components in place, it's time to replace DFS Replication with File Sync-based replication.

The main tasks for this exercise are:

1. Add **SEA-SVR1** as a server endpoint.
1. Register **SEA-SVR2** with File Sync.
1. Remove DFS Replication and add **SEA-SVR2** as a server endpoint.

#### Task 1: Add SEA-SVR1 as a server endpoint

1. On **SEA-ADM1**, in the Azure portal, download the File Sync agent for Windows Server 2022 (**StorageSyncAgent_WS2022.msi**), and then save it to the **C:\\\\Labfiles\\Lab10** folder.
1. On **SEA-ADM1**, in File Explorer, browse to the **C:\\Labfiles\\Lab10** folder, and open **Install-FileSyncServerCore.ps1** in the script pane of the Windows PowerShell ISE window.
1. In the **Windows PowerShell ISE** script pane, review the script, and then execute it to install the File Sync agent on **SEA-SVR1**.
1. When prompted, authenticate to your Azure subscription. 
1. In the Azure portal, refresh the registered servers in the **FileSync1** Storage Sync Service, and then point out that **SEA-SVR1.Contoso.com** is now registered.
1. In File Explorer, open **\\\\SEA-SVR1\\Data**, and then point out that the folder doesn't contain **File1.txt**.
1. Use the Azure portal to add **S:\\Data** on **SEA-SVR2.Contoso.com** as a server endpoint to **Sync1**.
1. Use File Explorer to verify that **File1.txt** is available on **\\\\SEA-SVR1\\Data\\**.

   >**Note:** You uploaded **File1.txt** to the **File1.txtAzure** file share, from where it was synced to **SEA-SVR2** by File Sync.

#### Task 2: Register SEA-SVR2 with File Sync

1. On **SEA-ADM1**, in the Windows PowerShell ISE window displaying the **Install-FileSyncServerCore.ps1** script, replace `SEA-SVR1` with `SEA-SVR2`, and then save the change.
1. Run **C:\\Labfiles\\Lab10\\Install-FileSyncServerCore.ps1** to install the File Sync agent on **SEA-SVR2**.
1. When prompted, authenticate to your Azure subscription. 
1. Use the Azure portal to verify that **SEA-SVR2.Contoso.com** and **SEA-SVR1.Contoso.com** are registered with the **FileSync1** Storage Sync Service.

#### Task 3: Remove DFS Replication and add SEA-SVR2 as a server endpoint

1. On **SEA-ADM1**, use **DFS Management** to delete the **Branch1** replication group.
1. Use the Azure portal to add **S:\\Data** on **SEA-SVR2.Contoso.com** as a server endpoint to **Sync1**.

### Results

After completing this exercise, you'll have replaced DFS Replication with File Sync.

## Exercise 4: Verifying replication and enabling cloud tiering

### Scenario

Exercise scenario: You now need to verify that you have successfully replaced DFS Replication with File Sync, and after confirming this, you need to enable cloud tiering.

The main tasks for this exercise are:

1. Verify File Sync.
1. Enable cloud tiering.

#### Task 1: Verify File Sync

1. On **SEA-ADM1**, use two instances of File Explorer to display the content of **\\\\SEA-SVR1\\Data** and **\\\\SEA-SVR2\\Data**.
1. Create a file with an arbitrary name in the **\\\\SEA-SVR1\\Data** folder.
1. Verify that shortly afterwards the file with the same name appears in the **\\\\SEA-SVR2\\Data** folder.

   >**Note** You removed DFS Replication in the previous exercise, which means that File Sync replicated the newly created file.

#### Task 2: Enable cloud tiering

1. On **SEA-ADM1**, use the Azure portal to browse to the **Sync1** sync group in the **FileSync1** Storage Sync Service.
1. In the Azure portal, enable cloud tiering for the **SEA-SVR1.Contoso.com** endpoint in **Sync1**. Set the **free disk space** policy to **80** percent and the **date policy** to cache files that were accessed in the last **7** days.
1. In the File Explorer instance that's connected to the **\\\\SEA-SVR1\\Data** folder, in the details pane, add the **Attributes** column by right-clicking or accessing the context menu for the **Title** column; for example, in the **Name** column, select **More**, and then select **Attributes**.

   >**Note:** After some time, files on **SEA-SVR2** would be automatically tiered. You will trigger this process by using PowerShell.

1. On **SEA-ADM1**, in **Windows PowerShell ISE**, from the console pane, trigger tiering immediately by running the following commands:

   ```powershell
   Enter-PSSession -computername SEA-SVR2
   fsutil file createnew S:\Data\report1.docx 254321098
   fsutil file createnew S:\Data\report2.docx 254321098
   fsutil file createnew S:\Data\report3.docx 254321098
   fsutil file createnew S:\Data\report4.docx 254321098
   Import-Module "C:\Program Files\Azure\StorageSyncAgent\StorageSync.Management.ServerCmdlets.dll"
   Invoke-StorageSyncCloudTiering -Path S:\Data 
   ```
1. On **SEA-ADM1**, switch to File Explorer, and then, on the **\\\\SEA-SVR2\\Data** share, identify files with the attribute **L**, **M**, and **O** (which indicate that the tiering took place).

### Results

After completing this exercise, you'll have created a working File Sync replication and a configured cloud tiering.

## Exercise 5: Troubleshooting replication issues

### Scenario

Exercise scenario: Contoso relies heavily on its DFS Replication implementation. You must ensure that any replication issues, including replication conflicts, can be quickly identified and resolved. To do so, you'll simulate the most common replication issues in your proof-of-concept environment and test their resolutions.

The main tasks for this exercise are:

1. Monitor File Sync replication.
1. Test replication conflict resolution.

#### Task 1: Monitor File Sync replication

1. On **SEA-ADM1**, use File Explorer to copy the **C:\\Windows\\INF** folder to **\\\\SEA-SVR1\Data\\**. The folder will sync to the cloud endpoint, causing sync traffic.
1. In the Azure portal, browse to the **Sync1** sync group in the **FileSync1** Storage Sync Service.
1. In the **Server endpoint** section, verify **Health** of both endpoints.
1. Select the **SEA-SVR1.Contoso.com** endpoint, and then, in the Server Endpoint Properties pane, review **Sync Activity**.
1. Select the **Files Synced** graph and explore how you can customize the graph by using a filter.
1. Verify if the **INF** folder is syncing to drive **Z**.
1. In the Azure portal, verify that the **INF** sync traffic is reflected in the **Files Synced** and **Bytes Synced** graphs. The **INF** folder has more than 800 files, and its size is more than 40 megabytes (MB).

   >**Note:** You might need to refresh the page displaying the Azure portal to see the updated statistics.

#### Task 2: Test replication conflict resolution

1. On **SEA-ADM1**, position the File Explorer windows displaying the content of **\\\\SEA-SVR1\Data\\** and **\\\\SEA-SVR2\Data\\** side-by-side.
1. In the File Explorer window displaying the content of **\\\\SEA-SVR1\Data\\**, create a file named **Demo.txt**. 
1. In the File Explorer window displaying the content of **\\\\SEA-SVR2\Data\\**, create a file named **Demo.txt**. 
1. Add an arbitrary text to the first **Demo.txt** file and save the change.
1. Immediately afterwards, add an arbitrary text (different from the one you used in the previous step) to the second **Demo.txt** file and save the change.

   >**Note:** Make sure to save the change to the second file as soon as possible. You're creating files with the same name but different content to intentionally trigger a sync conflict.

1. In each File Explorer window, review their content and verify they contain, in addition to the **Demo.txt** file, the **Demo-SEA-SVR2.txt** file (and potentially **Demo-Cloud.txt**) also. 

   >**Note:** This is because File Sync detected a sync conflict and added a suffix representing the endpoint name (**SEA-SVR2**) or **Cloud** to the file that caused the conflict.

### Results

After completing this exercise, you'll have monitored File Sync replication and resolved replication conflicts.

## Exercise 6: Cleaning up the Azure subscription

Exercise scenario: To minimize Azure-related charges, you will clean up the Azure subscription.

#### Task 1: Delete the Azure resources that were created in the lab

1. On **SEA-ADM1**, use the Azure portal to browse to the **FileSync1 Storage Sync Service** page.
1. Remove **SEA-SVR1.Contoso.com** and **SEA-SVR2.Contoso.com** as registered servers.
1. Delete the **share1** cloud endpoint in the **Sync1** sync group.
1. Delete the **Sync1** sync group.
1. Delete the **FileSync1** Storage Sync Service and the Azure storage account that you created in the lab.
1. Delete the **AZ800-L1001-RG** resource group.

### Results

After completing this exercise, you'll have cleaned up the Azure resources that were created in the lab.
