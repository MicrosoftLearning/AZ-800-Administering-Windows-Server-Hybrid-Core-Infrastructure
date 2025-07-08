---
lab:
    title: 'Lab: Managing Windows Server'
    module: 'Module 3: Windows Server administration'
---

# Lab: Managing Windows Server

## Scenario

Contoso, Ltd. wants to implement several new servers in their environment, and they have decided to use Server Core. They also want to implement Windows Admin Center for remote management of both these servers and other servers in the organization.

## Objectives

- Implement and configure Windows Admin Center

## Estimated time: 45 minutes

## Lab setup

Virtual machines: **AZ-800T00A-SEA-DC1** and **AZ-800T00A-ADM1** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-800T00A-SEA-DC1** and **AZ-800T00A-SEA-ADM1** virtual machines are hosting the installation of **SEA-DC1** and **SEA-ADM1**.

1. Select **SEA-ADM1**.
1. Sign in using the credentials provided by the instructor.

For this lab, you'll use the available VM environment and an Microsoft Entra tenant.

## Exercise 1: Implementing and using remote server administration

### Scenario 

Now that you have deployed the Server Core servers, you need to implement Windows Admin Center for remote administration.

The main tasks for this exercise are as follows:

1. Install Windows Admin Center.
1. Add servers for remote administration.
1. Configure Windows Admin Center extensions.
1. Verify remote administration.
1. Administer servers with Remote PowerShell.

#### Task 1: Install Windows Admin Center

1. On **SEA-ADM1**, start **Windows PowerShell** as Administrator.
1. From the **Windows PowerShell** console, run the following command to download the latest version of Windows Admin Center:
	
   ```powershell
   $parameters = @{
	     Source = "https://aka.ms/WACdownload"
	     Destination = ".\WindowsAdminCenter.exe"
	}
	Start-BitsTransfer @parameters
   ```
1. Enter the following command and then press Enter to install Windows Admin Center:
	
   ```powershell
  	Start-Process -FilePath '.\WindowsAdminCenter.exe' -ArgumentList '/VERYSILENT' -Wait
   ```
   > **Note**: Wait until the installation completes. This should take about 2 minutes.

   > **Note**: After installation completes, you may encounter the error message 'ERR_Connection_Refused'. If this occurs, restart SEA-ADM1 to correct the issue.

#### Task 2: Add servers for remote administration

1. On **SEA-ADM1**, start Microsoft Edge, and then go to `https://SEA-ADM1.contoso.com`. 
1. When prompted, sign in by using the credentials provided by the instructor.
1. Review the **All connections** page and note that it includes the **sea-adm1.contoso.com** entry. 
1. In the All connections pane, add a connection to `sea-dc1.contoso.com`.
1. When prompted, sign in by using the credentials provided by the instructor.

   > **Note**: To perform single sign-on, you would need to set up Kerberos constrained delegation.

#### Task 3: Configure Windows Admin Center extensions

1. On **SEA-ADM1**, in the upper-right corner, select the **Settings** icon (the cog wheel).
1. Review the available extensions.
1. Install the **DNS** extension. The extension will install and Windows Admin Center will refresh.

1. Verify that the list of installed extensions includes the DNS extension.
1. On the top menu, next to **Settings**, select the drop-down arrow, and then select **Server Manager**.
1. Within Windows Admin Center, connect to `sea-dc1.contoso.com`, and if needed, sign in by using the credentials provided by the instructor.
1. Connect to the DNS server on `sea-dc1.contoso.com` and install the DNS PowerShell tools.
1. Select the **Contoso.com** zone and review the list of its DNS records.

#### Task 4: Verify remote administration

1. On **SEA-ADM1**, in Windows Admin Center, while connected to `sea-dc1.contoso.com`, review the Overview pane. Note that the details pane of Windows Admin Center displays basic server information and performance monitoring.
1. In Windows Admin Center, install **Telnet Client** on `sea-dc1.contoso.com` by using the Roles & features tool. 
1. In Windows Admin Center, use the **Settings** interface to enable Remote Desktop on `sea-dc1.contoso.com`.
1. In Windows Admin Center, connect via Remote Desktop to `sea-dc1.contoso.com`.
1. Disconnect from the Remote Desktop session. 
1. Close the Microsoft Edge window.

#### Task 5: Administer servers with Remote PowerShell

1. On **SEA-ADM1**, switch to the **Windows PowerShell** console.
1. In the **Windows PowerShell** console, run the following command to start a PowerShell Remoting session to **SEA-DC1**:

   ```powershell
   Enter-PSSession -ComputerName SEA-DC1
   ```
1. From the **[SEA-DC1]** prompt, run the following command to display the status of the Application Identity service (AppIDSvc):

   ```powershell
   Get-Service -Name AppIDSvc
   ```

   > **Note**: Verify that the service is currently stopped.

1. From the **[SEA-DC1]** prompt, run the following command to start the Application Identity service:

   ```powershell
   Start-Service -Name AppIDSvc
   ```
1. From the **[SEA-DC1]** prompt, run the following command to display the status of the Application Identity service (AppIDSvc):

   ```powershell
   Get-Service -Name AppIDSvc
   ```

   > **Note**: Verify that the service is currently running.

### Results

After completing this exercise, you will have installed Windows Admin Center and connected it to the servers in your lab environment. You performed a number of remote management tasks including installing a feature as well as enabling and testing Remote Desktop connectivity. Finally, you used PowerShell Remoting to check the status of a service and then to start it.
