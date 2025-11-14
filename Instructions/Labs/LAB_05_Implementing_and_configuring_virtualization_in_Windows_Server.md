---
lab:
    title: 'Lab: Implementing and configuring virtualization in Windows Server'
    module: 'Module 5: Hyper-V virtualization in Windows Server'
---

# Lab: Implementing and configuring virtualization in Windows Server

## Scenario

Contoso is a global engineering and manufacturing company with its head office in Seattle, USA. An IT office and data center are in Seattle to support the Seattle location and other locations. Contoso recently deployed a Windows Server server and client infrastructure. 

Because of many physical servers being currently underutilized, the company plans to expand virtualization to optimize the environment. Because of this, you decide to perform a proof of concept to validate how Hyper-V can be used to manage a virtual machine environment. Also, the Contoso DevOps team wants to explore container technology to determine whether they can help reduce deployment times for new applications and to simplify moving applications to the cloud. You plan to work with the team to evaluate Windows Server containers and to consider providing Internet Information Services (Web services) in a container.

## Objectives

After completing this lab, you'll be able to:

- Create and configure VMs.
- Install and configure containers.

## Estimated time: 60 minutes

## Lab Setup

Virtual machines: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, and **AZ-800T00A-ADM1** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, and **AZ-800T00A-SEA-ADM1** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1** and **SEA-ADM1**

1. Select **SEA-ADM1**.
1. Sign in using the credentials provided by the instructor.

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
   $parameters = @{
     Source = "https://aka.ms/WACdownload"
     Destination = ".\WindowsAdminCenter.exe"
     }
   Start-BitsTransfer @parameters
   ```
1. Enter the following command, and then press Enter to install Windows Admin Center:
	
   ```powershell
   Start-Process -FilePath '.\WindowsAdminCenter.exe' -ArgumentList '/VERYSILENT' -Wait
   ```

   > **Note**: Wait until the installation completes. This should take about 2 minutes.

1. On **SEA-ADM1**, start Microsoft Edge and connect to the local instance of Windows Admin Center at `https://SEA-ADM1.contoso.com`. 
1. If prompted, in the **Windows Security** dialog box, enter the credentials providd by the instructor, and then select **OK**.

1. In Windows Admin Center, add a connection to **sea-svr1.contoso.com** and connect to it with the credentials providd by the instructor.
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

1. On **SEA-ADM1**, in the **Tools** listing for **SEA-SVR1**, select **PowerShell**. When prompted, authenticate with the credentials provided by the instructor, and then press Enter. 

   > **Note**: This establishes a PowerShell Remoting connection to SEA-SVR1.

   > **Note**: The Powershell connection in Windows Admin Center may be relatively slow due to nested virtualization used in the lab, so an alternate method is to run `Enter-PSSession -ComputerName SEA-SVR1` from a Windows Powershell console on **SEA-ADM1**.

1. In the **Windows PowerShell** console, enter the following commands, and then press Enter to install the Docker CE (Community Edition) on **SEA-SVR1**:

   ```powershell
   Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1

   .\install-docker-ce.ps1
   ```
 
1. After the installation completes, enter the following command, and then press Enter to restart **SEA-SVR1**:

   ```powershell
   Restart-Computer -Force
   ```

#### Task 2: Install and run a Windows container


1. After **SEA-SVR1** restarts, use the PowerShell tool again to establish a new PowerShell Remoting session to **SEA-SVR1**.

   > **Note**: For the remaining steps in this task, you will need to run interactive Docker commands that require a TTY-capable terminal. The PowerShell console in Windows Admin Center does not support TTY. Therefore, it is recommended to use the alternative method: open **Windows PowerShell** as Administrator on **SEA-ADM1** and run `Enter-PSSession -ComputerName SEA-SVR1` to establish a PowerShell Remoting session.

1. In the **Windows PowerShell** console, enter the following command, and then press Enter to identify Docker images currently present on **SEA-SVR1**: 

   ```powershell
   docker images
   ```

   > **Note**: Verify that there are no images in the local repository store.

1. Enter the following command, and then press Enter to download a Nano Server image:

   ```powershell
   docker pull mcr.microsoft.com/windows/nanoserver:ltsc2022
   ```

   > **Note**: The time it takes to complete the download will depend on the available bandwidth of the network connection from the lab VM to the Microsoft container registry.

1. Enter the following command, and then press Enter to verify that the Docker image has been successfully downloaded:

   ```powershell
   docker images
   ```

1. Enter the following command, and then press Enter to launch a container based on the downloaded image:

   ```powershell
   docker run -it mcr.microsoft.com/windows/nanoserver:ltsc2022 cmd.exe 
   ```

   > **Note**: The docker command starts a container and connects you to the command line interface of the container. 

1. Enter the following command, and then press Enter to retrieve the IP address information of the container host:

   ```powershell
   hostname
   ```
    > **Note**: Verify this is the hostname of the container instance, not **SEA-SVR1**.

1. Enter the following command, and then press Enter to create a text file in the container:

   ```powershell
   echo "Hello World!" > C:\Users\Public\Hello.txt
   ```

1. Enter the following command, and then press Enter to exit the command line interface of the container and return to the PowerShell prompt on **SEA-SVR1**:

   ```powershell
   exit
   ```

1. Enter the following command, and then press Enter get the container ID for the container you just exited by running the docker ps command:

   ```powershell
   docker ps -a
   ```
   > **Note**: The `-a` switch lists all containers, including those that are not currently running.

1. Create a new helloworld image that includes the changes in the first container you ran. To do so, run the docker commit command, replacing \<containerID\> with the ID of your container:

   ```powershell
   docker commit <containerID> helloworld
   ```

1. You now have a custom image that contains the Hello.txt file. You can use the docker images command to see the new image.

   ```powershell
   docker images
   ```

1. Run the new container by using the docker run command with the --rm option. When you use this option, Docker automatically removes the container when the command, cmd.exe in this case, stops.

   ```powershell
   docker run --rm helloworld cmd.exe /s /c type C:\Users\Public\Hello.txt
   ```
   > **Note**: This command line outputs the content of the file you created earlier and stops the container again.

1. Enter the following command, and then press Enter to launch a new container instance of the original image and check if the file you created is present:

   ```powershell
   docker run --rm mcr.microsoft.com/windows/nanoserver:ltsc2022 cmd.exe /s /c type C:\Users\Public\Hello.txt
   ```
   > **Note**: The original image was not modified by adding a file and reverted back to its original state after stopping.

#### Task 3: Use Windows Admin Center to manage containers

1. On **SEA-ADM1**, in the Windows Admin Center, go to the settings icon in the top left corner, and then select **Extensions**.

1. In the **Extensions** pane, verify the **Containers** extension is installed and updated under **Installed Extension**. If the extension is not installed, add it from the **Available Extensions** pane.

1. On **SEA-ADM1**, in the Windows Admin Center, in the Tools menu of **sea-svr1.contoso.com**, select **Containers**. When prompted to close the **PowerShell** session, select **Continue**.

1. In the Containers pane, browse through the **Overview**, **Containers**, **Images**, **Networks**, and **Volumes** tabs.

### Exercise 2 results

After this exercise, you should have installed Docker on Windows Server, downloaded a Windows container image containing web services, and verified its functionality.
