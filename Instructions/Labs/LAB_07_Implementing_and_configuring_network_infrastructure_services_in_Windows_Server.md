---
lab:
    title: 'Lab: Implementing and configuring network infrastructure services in Windows Server'
    module: 'Module 7: Network Infrastructure services in Windows Server'
---

# Lab: Implementing and configuring network infrastructure services in Windows Server

## Scenario

Contoso, Ltd. is a large organization with complex requirements for network services. To help meet these requirements, you will deploy and configure DHCP so that it is highly available to ensure service availability. You will also set up DNS so that Trey Research, a department within Contoso, can have its own DNS server in the testing area. Finally, you will provide remote access to Windows Admin Center and secure it with Web Application Proxy.

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-800%20Lab%20Simulation%20-%20Implementing%20and%20configuring%20network%20infrastructure%20services%20in%20Windows%20Server)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Objectives

After completing this lab, you'll be able to:

- Deploy and configure DHCP.
- Deploy and configure DNS.

## Estimated time: 60 minutes

## Lab Setup

Virtual machines: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, and **AZ-800T00A-ADM1** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-800T00A-SEA-DC1**, **AZ-800T00A-SEA-SVR1**, and **AZ-800T00A-SEA-ADM1** virtual machines are hosting the installation of **SEA-DC1**, **SEA-SVR1**, and **SEA-ADM1**

1. Select **SEA-ADM1**.
1. Sign in using the credentials provided by the instructor.

For this lab, you'll use the available VM environment.

## Exercise 1: Deploying and configuring DHCP

### Scenario

The Trey Research subdivision of Contoso has a separate office with only about 50 users. They have been manually configuring IP addresses on all of their computers and want to begin using DHCP instead. You will install DHCP on **SEA-SVR1** with a scope for the Trey Research site. Additionally, you will configure DHCP Failover by using the new DHCP server for high availability with **SEA-DC1**.

The main tasks for this exercise are as follows:

1. Install the DHCP role.
1. Authorize the DHCP server.
1. Create a scope.
1. Configure DHCP Failover.
1. Verify DHCP functionality.

### Task 1: Install the DHCP role

1. On **SEA-ADM1**, start Windows PowerShell as Administrator.

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

   >**Note**: If the link does not work, on **SEA-ADM1**, browse to the **WindowsAdminCenter.msi** file, open the context menu for it, and then select **Repair**. After the repair completes, refresh Microsoft Edge. 
   
1. If prompted, in the **Windows Security** dialog box, enter the credentials provided by the instructor, and then select **OK**.

1. In Windows Admin Center, add a connection to **sea-svr1.contoso.com** and connect to it with the credentials provided by the instructor.
1. In the **Tools** list, use **Roles & features** to install the DHCP role on **SEA-SVR1**.
1. In the **Tools** list, browse to the **DHCP** tool and install the **DHCP PowerShell** tools. 

   > **Note**: If the **DHCP** entry is not available in the Tools pane for **sea-svr1.contoso.com**, refresh the **Microsoft Edge** page and try again.

### Task 2: Authorize the DHCP server

1. On **SEA-ADM1**, open Server Manager.
1. In Server Manager, open **Notifications**, open **Complete DHCP configuration**, and then complete the **DHCP Post-Install Configuration Wizard** by using the default options.

### Task 3: Create a scope

1. On **SEA-ADM1**, in Windows Admin Center, while connected to **sea-svr1.contoso.com**, use the **DHCP** tool to create a new scope with the following settings:

   - Protocol: **IPv4**
   - Name: **ContosoClients**
   - Starting IP address: **10.100.150.50**
   - Ending IP address: **10.100.150.254**
   - DHCP client subnet mask: **255.255.255.0**
   - Router (default gateway): **10.100.150.1**
   - Lease duration for DHCP clients: **4 days**

1. From the **Tools** menu of Server Manager, open the **DHCP management console**.
1. In the **DHCP management console**, add all authorized servers (**172.16.10.12** and **SEA-DC1.contoso.com**).
1. In the **DHCP management console**, browse to the DHCP server **172.16.10.12** node, and then, in the **ContosoClients** scope, add the scope option **006 DNS Servers** with the value **172.16.10.10**.

### Task 4: Configure DHCP Failover

1. On **SEA-ADM1**, in the **DHCP** management console, browse to the **IPv4** node of the DHCP server **172.16.10.12** and configure failover of the **ContosoClients** scope with **SEA-DC1.contoso.com** using the following settings:

   - Relationship Name: **SEA-SVR1 to SEA-DC1**
   - Maximum Client Lead Time: **1 hour**
   - Mode: **Hot standby**
   - Role of Partner Server: **Standby**
   - Addresses reserved for standby server: **5%**
   - State Switchover Interval: **Disabled**
   - Enable Message Authentication: **Enabled**
   - Shared Secret: **DHCP-Failover**

1. Verify that **SEA-SVR1** has only one scope.
1. Verify that **SEA-DC1** has now two scopes.
1. On **SEA-ADM1**, in the **DHCP** management console, browse to the **IPv4** node of the DHCP server **SEA-DC1.contoso.com** and configure failover of the **Contoso** scope with **172.16.10.12**, using the settings of the existing failover relationship.
1. Verify that both scopes now appear within the **IPv4** node of **172.16.10.12** (**SEA-SVR1**).

### Task 5: Verify DHCP functionality

1. On **SEA-ADM1**, change the IP configuration from statically to dynamically assigned.
1. Examine the resulting IP configuration and verify that the DHCP lease was obtained from **SEA-SVR1 (172.16.10.12)**.
1. On **SEA-ADM1**, in the **DHCP management console**, verify that both DHCP servers list the lease for **SEA-ADM1** in the **Contoso** scope.
1. On **SEA-ADM1**, use the **DHCP management console** to stop the **DHCP** service on **SEA-SVR1 (172.16.10.12)**.
1. Force renewal of the lease by disabling and re-enabling the Ethernet network connection on **SEA-ADM1**.
1. On **SEA-ADM1**, verify that the same DHCP lease is obtained from **SEA-DC1 (172.16.10.10)**.

## Exercise 2: Deploying and configuring DNS

### Scenario

The staff who work at the Trey Research location within Contoso need to have their own DNS server to create records in their test environment. However, their test environment still needs to be able to resolve Internet DNS names and resource records for Contoso. To meet these needs, you are configuring forwarding to your Internet service provider (ISP) and creating a conditional forwarder for **contoso.com** to **SEA-DC1**. There is also a test application that needs a different IP address resolution based on user location. You are using DNS policies to configure **testapp.treyresearch.net** to resolve differently for users at the head office.

The main tasks for this exercise are as follows:

1. Install the DNS role.
1. Create a DNS zone.
1. Configure forwarding.
1. Configure conditional forwarding.
1. Configure DNS policies.
1. Verify DNS policy functionality.

### Task 1: Install the DNS role

1. On **SEA-ADM1**, use **Roles & features** in the **Tools** list of Windows Admin Center connected to **sea-svr1.contoso.com** to install the DNS role on **SEA-SVR1**.
1. In the **Tools** list, browse to the **DNS** tool and install the **DNS PowerShell** tools. 

   > **Note**: If the **DNS** entry is not available in the **Tools** list for **sea-svr1.contoso.com**, refresh the **Microsoft Edge** page and try again.

### Task 2: Create a DNS zone

1. On **SEA-ADM1**, in Windows Admin Center, while connected to **sea-svr1.contoso.com**, use the **DNS** tool to create a new DNS zone with the following settings:

   - Zone type: **Primary**
   - Zone name: **TreyResearch.net**
   - Zone file: **Create a new file**
   - Zone file name: **TreyResearch.net.dns**
   - Dynamic update: **Do not allow dynamic update**

1. In Windows Admin Center, while connected to **sea-svr1.contoso.com**, use the **DNS** tool to create a new DNS record in the **TreyResearch.net** zone with the following settings:

   - DNS record type: **Host (A)**
   - Record name: **TestApp**
   - IP address: **172.30.99.234**
   - Time to live: **600**

1. On **SEA-ADM1**, in the **Windows PowerShell** console, run the following command to verify that the newly created record resolves properly:

    ```powershell
    Resolve-DnsName -Server sea-svr1.contoso.com -Name testapp.treyresearch.net
    ```

### Task 3: Configure forwarding

1. On **SEA-ADM1**, from the **Tools** menu of Server Manager, open the **DNS Manager console**.
1. In **DNS Manager**, connect to **SEA-SVR1.contoso.com**.
1. In the properties of **SEA-SVR1.contoso.com**, on the **Forwarders** tab, configure **131.107.0.100** as a forwarder.

### Task 4: Configure conditional forwarding

1. On **SEA-ADM1**, in **DNS Manager**, while connected to **SEA-SVR1.contoso.com**, create a new conditional forwarder for **Contoso.com** that forwards requests to **SEA-DC1.contoso.com** (**172.16.10.10**).
1. On **SEA-ADM1**, in the **Windows PowerShell** console, run the following command to verify that the conditional forwarder is operational:

    ```powershell
    Resolve-DnsName -Server sea-svr1.contoso.com -Name sea-dc1.contoso.com
    ```

### Task 5: Configure DNS policies

1. On **SEA-ADM1**, in Windows Admin Center, while connected to **sea-svr1.contoso.com**, use **PowerShell** in the **Tools** list to establish PowerShell Remoting session.
1. At the **Windows PowerShell** prompt, run the following command to create a head office subnet:

    ```powershell
    Add-DnsServerClientSubnet -Name "HeadOfficeSubnet" -IPv4Subnet "172.16.10.0/24"
    ```

1. Run the following command to create a zone scope for head office:

    ```powershell
    Add-DnsServerZoneScope -ZoneName "TreyResearch.net" -Name "HeadOfficeScope"
    ```

1. Run the following command to create a new resource record for the head office scope:

    ```powershell
    Add-DnsServerResourceRecord -ZoneName "TreyResearch.net" -A -Name "testapp" -IPv4Address "172.30.99.100" -ZoneScope "HeadOfficeScope"
    ```

1. Run the following command to create a new policy that links the head office subnet and the zone scope:

    ```powershell
    Add-DnsServerQueryResolutionPolicy -Name "HeadOfficePolicy" -Action ALLOW -ClientSubnet "eq,HeadOfficeSubnet" -ZoneScope "HeadOfficeScope,1" -ZoneName "TreyResearch.net"
    ```

### Task 6: Verify DNS policy functionality

1. On **SEA-ADM1**, in the **Windows PowerShell** console, run `ipconfig` to verify that **SEA-ADM1** is on the **HeadOfficeSubnet (172.16.10.0)**.
1. In the **Windows PowerShell** console, run the following command to test the DNS policy:

    ```powershell
    Resolve-DnsName -Server sea-svr1.contoso.com -Name testapp.treyresearch.net
    ```

   > **Note**: Verify that the name resolves to the IP address **172.30.99.100** that was configured in the **HeadOfficePolicy**.

1. Change the IP address assigned to **SEA-ADM1** from **172.16.10.11** to an IP address (**172.16.11.11**) that is not within the IP address range of the **HeadOfficeSubnet**.
1. In the **Windows PowerShell** console, run the following command to test the DNS policy:

    ```powershell
    Resolve-DnsName -Server sea-svr1.contoso.com -Name testapp.treyresearch.net
    ```
   > **Note**: Verify that the name resolves to **172.30.99.234**. This is expected, because the IP address of **SEA-ADM1** is no longer within the **HeadOfficeSubnet**. DNS queries originating from the **HeadOfficeSubnet** of **(172.16.10.0/24)** targeting `testapp.treyresearch.net` resolve to **172.30.99.100**. DNS queries from outside of this subnet targeting `testapp.treyresearch.net` resolve to **172.30.99.234**.

1. Change the IP address of **SEA-ADM1** back to its original value.
