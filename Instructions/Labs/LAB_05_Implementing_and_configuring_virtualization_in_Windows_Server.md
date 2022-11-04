---
lab:
    title: 'Lab: Implementing and configuring virtualization in Windows Server'
    module: 'Module 5: Hyper-V virtualization in Windows Server'
---

# Lab: Implementing and configuring virtualization in Windows Server

## Scenario

Contoso is a global engineering and manufacturing company with its head office in Seattle, USA. An IT office and data center are in Seattle to support the Seattle location and other locations. Contoso recently deployed a Windows Server server and client infrastructure. 

Because of many physical servers being currently underutilized, the company plans to expand virtualization to optimize the environment. Because of this, you decide to perform a proof of concept to validate how Hyper-V can be used to manage a virtual machine environment. Also, the Contoso DevOps team wants to explore container technology to determine whether they can help reduce deployment times for new applications and to simplify moving applications to the cloud. You plan to work with the team to evaluate Windows Server containers and to consider providing Internet Information Services (Web services) in a container.

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-800%20Lab%20Simulation%20-%20Implementing%20and%20configuring%20virtualization%20in%20Windows%20Server)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Objectives

After completing this lab, you'll be able to:

- Create and configure VMs.
- Install and configure containers.

## Estimated time: 60 minutes

## Lab Setup

Virtual machines: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, and **AZ-800T00A-ADM1** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, and **AZ-800T00A-SEA-ADM1** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1** and **SEA-ADM1**

1. Select **SEA-ADM1**.
1. Sign in using the following credentials:

   - User name: **Administrator**
   - Password: **Pa55w.rd**
   - Domain: **CONTOSO**

For this lab, you'll use the available VM environment.

## Exercise 1: Creating and configuring VMs

### Scenario

In this exercise, you will use Hyper-V Manager and Windows Admin Center to create and configure a virtual machine. You will start with creating a private virtual network switch. Next, you decide to create a differencing drive of a base image that has already been prepared with the operating system to be installed on the VM. Finally, you will create a generation 1 VM that uses the differencing drive and private switch that you have prepared for the proof of concept.

The main tasks for this exercise are as follows:

1. Create a Hyper-V virtual switch
1. Create a virtual hard disk
1. Create a virtual machine
1. Manage virtual machines using Windows Admin Center

#### Task 1: Create a Hyper-V virtual switch

1. On **SEA-ADM1**, open **Server Manager**. 
1. In Server Manager, select **All Servers**. 
1. In the Servers list, select **SEA-SVR1** and use its context-sensitive menu to start **Hyper-V Manager** targeting that server. 
1. In **Hyper-V Manager**, use the **Virtual Switch Manager** to create on **SEA-SVR1** a virtual switch with the following settings:

   - Name: **Contoso Private Switch**
   - Connection type: **Private network**

#### Task 2: Create a virtual hard disk

1. On **SEA-ADM1**, in Hyper-V Manager, use the **New Virtual Hard Disk Wizard** to create on **SEA-SVR1** a new virtual hard disk with the following settings: 

   - Disk Format: **VHD**
   - Disk Type: **Differencing**
   - Name: **SEA-VM1**
   - Location: **C:\Base**
   - Parent Disk: **C:\Base\BaseImage.vhd**

#### Task 3: Create a virtual machine

1. On **SEA-ADM1**, in Hyper-V Manager, on **SEA-SVR1**, create a new virtual machine with the following settings: 

   - Name: **SEA-VM1**
   - Location: **C:\Base**
   - Generation: **Generation 1**
   - Memory: **4096**
   - Networking: **Contoso Private Switch**
   - Hard disk: **C:\Base\SEA-VM1.vhd**

1. Open the **Settings** window for **SEA-VM1** and enable **Dynamic Memory** with a Maximum RAM value of **4096**.
1. Close Hyper-V Manager.

#### Task 4: Manage Virtual Machines using Windows Admin Center

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
1. If prompted, in the **Windows Security** dialog box, enter the following credentials, and then select **OK**:

   - Username: **CONTOSO\\Administrator**
   - Password: **Pa55w.rd**

1. In Windows Admin Center, add a connection to **sea-svr1.contoso.com** and connect to it as **CONTOSO\\Administrator** with the password of **Pa55w.rd**. 
1. In the **Tools** list, select **Virtual Machines** and review the **Summary** pane.
1. In the **Inventory** pane open **SEA-VM1** and review the **Setting**.
1. Use Windows Admin Center to create a new disk, 5 GB in size.
1. Use Windows Admin Center to start **SEA-VM1**, and then display the statistics for the running VM.
1. Use Windows Admin Center to shut down **SEA-VM1**.
1. In the **Tools** list, select **Virtual switches** and identify the existing switches.

### Exercise 1 results

After this exercise, you should have used Hyper-V Manager and Windows Admin Center to create a virtual switch, a virtual hard disk, a virtual machine, and then manage the virtual machine.

## Exercise 2: Installing and configuring containers

### Scenario

In this exercise, you will use Docker to install and run Windows containers. You will also use Windows Admin Center to manage containers.

The main tasks for this exercise are as follows:

1. Install Docker on Windows Server
1. Install and run a Windows container
1. Use Windows Admin Center to manage containers

#### Task 1: Install Docker on Windows Server

1. On **SEA-ADM1**, in Windows Admin Center, while connected to **sea-svr1.contoso.com**, use the **Tools** menu to establish a PowerShell Remoting session to that server. 

   > **Note**: The Powershell connection in Windows Admin Center may be relatively slow due to nested virtualization used in the lab, so an alternate method is to run `Enter-PSSession -ComputerName SEA-SVR1` from a Windows Powershell console on **SEA-ADM1**.

1. In the PowerShell console, run the following commands to force the use of TLS 1.2 and install the PowerShellGet module: 

   ```powershell
   [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
   Install-PackageProvider -Name NuGet -Force
   Install-Module PowerShellGet -RequiredVersion 2.2.4 -SkipPublisherCheck
   ```
1. After the installation completes, run the following command to restart **SEA-SVR1**:

   ```powershell
   Restart-Computer -Force
   ```
1. After **SEA-SVR1** restarts, use the **PowerShell** tool again to establish a new PowerShell Remoting session to **SEA-SVR1**.

1. In the **Windows PowerShell** console, run the following command to install the Docker Microsoft PackageManagement provider on **SEA-SVR1**:

   ```powershell
   Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
   ```
1. In the **Windows PowerShell** console, run the following command to install the Docker runtime on **SEA-SVR1**:

   ```powershell
   Install-Package -Name docker -ProviderName DockerMsftProvider
   ```
1. After the installation completes, run the following commands to restart **SEA-SVR1**:

   ```powershell
   Restart-Computer -Force
   ```

#### Task 2: Install and run a Windows container

1. After **SEA-SVR1** restarts, use the **PowerShell** tool again to establish a new PowerShell Remoting session to **SEA-SVR1**.
1. In the **Windows PowerShell** console, run the following command to verify the installed version of Docker:

   ```powershell
   Get-Package -Name Docker -ProviderName DockerMsftProvider
   ```
1. Run the following command to identify Docker images currently present on **SEA-SVR1**: 

   ```powershell
   docker images
   ```

   > **Note**: Verify that there are no images in the local repository store.

1. Run the following command to download a Nano Server image containing an Internet Information Services (IIS) installation:

   ```powershell
   docker pull nanoserver/iis
   ```

   > **Note**: The time it takes to complete the download will depend on the available bandwidth of the network connection from the lab VM to the Microsoft container registry.

1. Run the following command to verify that the Docker image has been successfully downloaded:

   ```powershell
   docker images
   ```
1. Run the following command to launch a container based on the downloaded image:

   ```powershell
   docker run --isolation=hyperv -d -t --name nano -p 80:80 nanoserver/iis 
   ```

   > **Note**: The docker command starts a container in the Hyper-V isolation mode (which addresses any host operating system incompatibility issues) as a background service (`-d`) and configures networking such that port 80 of the container host maps to port 80 of the container. 

1. Run the following command to retrieve the IP address information of the container host:

   ```powershell
   ipconfig
   ```

   > **Note**: Identify the IPv4 address of the Ethernet adapter named vEthernet (nat). This is the address of the new container. Next, identify the IPv4 address of the Ethernet adapter named **Ethernet**. This is the IP address of the host (**SEA-SVR1**) and is set to **172.16.10.12**.

1. On **SEA-ADM1**, switch to the Microsoft Edge window, open another tab and go to **http://172.16.10.12**. Verify that the browser displays the default IIS page.
1. On **SEA-ADM1**, switch back to the PowerShell Remoting session to **SEA-SVR1** and, in the **Windows PowerShell** console, run the following command to list running containers:

   ```powershell
   docker ps
   ```
   > **Note**: This command provides information on the container that is currently running on **SEA-SVR1**. Record the container ID because you will use it to stop the container. 

1. Run the following command to stop the running container (replace the `<ContainerID>` placeholder with the container ID you identified in the previous step):

   ```powershell
   docker stop <ContainerID>
   ```
1. Run the following command to verify that the container has stopped:

   ```powershell
   docker ps
   ```

#### Task 3: Use Windows Admin Center to manage containers

1. On **SEA-ADM1**, in Windows Admin Center, in the **Tools** menu of **sea-svr1.contoso.com**, select **Containers**. When prompted to close the **PowerShell** session, select **Continue**.
1. In the Containers pane, browse through the **Overview**, **Containers**, **Images**, **Networks**, and **Volumes** tabs.

### Exercise 2 results

After this exercise, you should have installed Docker on Windows Server, downloaded a Windows container image containing web services, and verified its functionality.
