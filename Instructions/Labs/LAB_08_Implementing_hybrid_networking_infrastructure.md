---
lab:
    title: 'Lab: Implementing hybrid networking infrastructure'
    module: 'Module 8: Implementing Windows Server IaaS VM networking'
---

# Lab: Implementing hybrid networking infrastructure

## Scenario

You were tasked with building a test environment in Azure, consisting of Microsoft Azure virtual machines deployed into separate virtual networks configured in the hub and spoke topology. This testing must include implementing connectivity between spokes by using user-defined routes that force traffic to flow via the hub. You also need to implement DNS name resolution for Azure virtual machines between virtual networks by using Azure private DNS zones and evaluate the use of Azure DNS zones for external name resolution.

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-800%20Lab%20Simulation%20-%20Implementing%20hybrid%20networking%20infrastructure)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

## Objectives

After completing this lab, you'll be able to:

- Implement virtual network routing in Azure
- Implement DNS name resolution in Azure
- Deprovision the Azure environment

## Estimated time: 60 minutes

## Lab setup

Virtual machines: **AZ-800T00A-SEA-DC1** and **AZ-800T00A-ADM1** must be running. Other VMs can be running, but they aren't required for this lab.

> **Note**: **AZ-800T00A-SEA-DC1** and **AZ-800T00A-SEA-ADM1** virtual machines are hosting the installation of **SEA-DC1** and **SEA-ADM1**

1. Select **SEA-ADM1**.
1. Sign in using the following credentials:

   - Username: `Administrator`
   - Password: `Pa55w.rd`
   - Domain: `CONTOSO`

For this lab, you'll use the available VM environment and an Azure subscription. Before you begin the lab, ensure that you have an Azure subscription and a user account with the Owner or Contributor role in that subscription.

>**Note**: This lab, by default, requires a total of 6 vCPUs available in the Standard_Dsv3 series in the region you choose for deployment because it involves deployment of three Azure VMs of Standard_D2s_v3 SKU. If you are using a free Azure account, with the limit of 4 vCPUs, you can use a VM size that requires only one vCPU (such as Standard_B1s).

### Exercise 1: Implement virtual network routing in Azure

### Scenario

You will start by deploying core network infrastructure using an Azure Resource Manager template, configuring custom routing within that infrastructure, and validating its functionality. 

The main tasks for this exercise are as follows:

1. Provision lab infrastructure resources
1. Configure the hub and spoke network topology
1. Test transitivity of virtual network peering
1. Configure routing in the hub and spoke topology

#### Task 1: Provision lab infrastructure resources

In this task, you will deploy three virtual machines into the same Azure region but into separate virtual networks. The first virtual network will serve as a hub, while the other two will form spokes. These resources will serve as the basis for the lab infrastructure.

1. Connect to **SEA-ADM1**, and then, if needed, sign in as **CONTOSO\\Administrator** with a password of **Pa55w.rd**.
1. On **SEA-ADM1**, start Microsoft Edge, browse to the Azure portal at `https://portal.azure.com`, and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. In the Azure portal, open a PowerShell session in the Cloud Shell pane.
1. Upload the files **C:\\Labfiles\\Lab08\\L08-rg_template.json** and **C:\\Labfiles\\Lab08\\L08-rg_template.parameters.json** into the Cloud Shell home directory.
1. From the Cloud Shell pane, run the following commands to create the first resource group that will be hosting the lab environment (replace the `<Azure_region>` placeholder with the name of an Azure region that you intend to use for the deployment):

   >**Note**: You can run the **(Get-AzLocation).Location** command to list the names of available Azure regions:

    ```powershell 
    $location = '<Azure_region>'
    $rgName = 'AZ800-L0801-RG'
    New-AzResourceGroup -Name $rgName -Location $location
    ```
1. From the Cloud Shell pane, run the following command to create the three virtual networks and four Azure VMs into them by using the template and parameter files you uploaded:

   ```powershell
   New-AzResourceGroupDeployment `
      -ResourceGroupName $rgName `
      -TemplateFile $HOME/L08-rg_template.json `
      -TemplateParameterFile $HOME/L08-rg_template.parameters.json
   ```

    >**Note**: Wait for the deployment to complete before proceeding to the next step. This should take about 3 minutes.

1. From the Cloud Shell pane, run the following commands to install the Network Watcher extension on the Azure VMs deployed in the previous step:

   ```powershell
   $rgName = 'AZ800-L0801-RG'
   $location = (Get-AzResourceGroup -ResourceGroupName $rgName).location
   $vmNames = (Get-AzVM -ResourceGroupName $rgName).Name

   foreach ($vmName in $vmNames) {
     Set-AzVMExtension `
     -ResourceGroupName $rgName `
     -Location $location `
     -VMName $vmName `
     -Name 'networkWatcherAgent' `
     -Publisher 'Microsoft.Azure.NetworkWatcher' `
     -Type 'NetworkWatcherAgentWindows' `
     -TypeHandlerVersion '1.4'
   }
   ```

    >**Note**: Do not wait for the deployment to complete but instead proceed to the next step. The installation of the Network Watcher extension should take about 5 minutes.

#### Task 2: Configure the hub and spoke network topology

In this task, you will configure local peering between the virtual networks you deployed in the previous tasks to create a hub and spoke network topology.

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, open another tab and browse to the Azure portal at `https://portal.azure.com`.
1. In the Azure portal, browse to the **az800l08-vnet0** virtual network page.
1. From the **az800l08-vnet0** virtual network page, create a peering with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | This virtual network: Peering link name | **az800l08-vnet0_to_az800l08-vnet1** |
    | Traffic to remote virtual network | **Allow (default)** |
    | Traffic forwarded from remote virtual network | **Allow (default)** |
    | Virtual network gateway or Route Server | **None (default)** |
    | Remote virtual network: Peering link name | **az800l08-vnet1_to_az800l08-vnet0** |
    | Virtual network deployment model | **Resource manager** |
    | Remote virtual network: Virtual network | **az800l08-vnet1** |
    | Traffic to remote virtual network | **Allow (default)** |
    | Traffic forwarded from remote virtual network | **Allow (default)** |
    | Virtual network gateway | **None (default)** |

    >**Note**: Wait for the operation to complete.

    >**Note**: This step establishes two peerings - one from **az800l08-vnet0** to **az800l08-vnet1** and the other from **az800l08-vnet1** to **az800l08-vnet0**.

    >**Note**: **Allow forwarded traffic** needs to be enabled in order to facilitate routing between spoke virtual networks, which you will implement later in this lab.

1. Repeat the previous step to add a peering with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | This virtual network: Peering link name | **az800l08-vnet0_to_az800l08-vnet2** |
    | Traffic to remote virtual network | **Allow (default)** |
    | Traffic forwarded from remote virtual network | **Allow (default)** |
    | Virtual network gateway | **None (default)** |
    | Remote virtual network: Peering link name | **az800l08-vnet2_to_az800l08-vnet0** |
    | Virtual network deployment model | **Resource manager** |
    | Remote virtual network: Virtual network | **az800l08-vnet2** |
    | Traffic to remote virtual network | **Allow (default)** |
    | Traffic forwarded from remote virtual network | **Allow (default)** |
    | Virtual network gateway | **None (default)** |

    >**Note**: This step establishes two peerings - one from **az800l08-vnet0** to **az800l08-vnet2** and the other from **az800l08-vnet2** to **az800l08-vnet0**. This completes setting up the hub and spoke topology (with the **az800l08-vnet0** virtual network serving the role of the hub, while **az800l08-vnet1** and **az800l08-vnet2** are its spokes).

#### Task 3: Test transitivity of virtual network peering

In this task, you will test connectivity across virtual network peerings by using Network Watcher.

>**Note**: Before you start this task, make sure that the script you invoked in the first task of this exercise completed successfully.

1. In the Azure portal, browse to the **Network Watcher** page.
1. From the **Network Watcher - Connection troubleshoot** page, initiate a check with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Source type | **Virtual machine** |
    | Virtual machine | **az800l08-vm0** |
    | Destination | **Specify manually** |
    | URI, FQDN or IPv4 | **10.81.0.4** |
    | Protocol | **TCP** |
    | Destination Port | **3389** |

    > **Note**: **10.81.0.4** represents the private IP address of **az800l08-vm1**. The test uses the **TCP** port **3389** because Remote Desktop is by default enabled on Azure virtual machines and accessible within and between virtual networks.

1. Wait until results of the connectivity check are returned. Verify that the status is **Reachable**. Review the network path and note that the connection was direct, with no intermediate hops in between the VMs.

    > **Note**: This is expected because the hub virtual network is peered directly with the first spoke virtual network.

1. From the **Network Watcher - Connection troubleshoot** page, initiate another check with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Source type | **Virtual machine** |
    | Virtual machine | **az800l08-vm0** |
    | Destination | **Specify manually** |
    | URI, FQDN or IPv4 | **10.82.0.4** |
    | Protocol | **TCP** |
    | Destination Port | **3389** |

    > **Note**: **10.82.0.4** represents the private IP address of **az800l08-vm2**. 

1. Select **Check** and wait until results of the connectivity check are returned. Verify that the status is **Reachable**. Review the network path and note that the connection was direct, with no intermediate hops in between the VMs.

    > **Note**: This is expected because the hub virtual network is peered directly with the second spoke virtual network.

1. From the **Network Watcher - Connection troubleshoot** page, initiate yet another check with the following settings (leave others with their default values) and initiate another check:

    > **Note**: You might need to refresh the browser page for the virtual machine **az800l08-vm1** to appear in the **Virtual machine** drop-down list.

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Source type | **Virtual machine** |
    | Virtual machine | **az800l08-vm1** |
    | Destination | **Specify manually** |
    | URI, FQDN or IPv4 | **10.82.0.4** |
    | Protocol | **TCP** |
    | Destination Port | **3389** |

1. Wait until results of the connectivity check are returned. Note that the status is **Unreachable**.

    > **Note**: This is expected because the two spoke virtual networks are not peered with each other and virtual network peering is not transitive.

#### Task 4: Configure routing in the hub and spoke topology

In this task, you will configure and test routing between the two spoke virtual networks by enabling IP forwarding on the network interface of the **az800l08-vm1** virtual machine, enabling routing within its operating system, and configuring user-defined routes on the spoke virtual network.

1. In the Azure portal, browse to the page of the **az800l08-vm0** virtual machine.
1. On the **az800l08-vm0** virtual machine page, browse to the page displaying settings of its network interface **az800l08-nic0**.
1. On the **az800l08-nic0** network interface page, display its **IP configurations** page and enable **IP forwarding**.

   > **Note**: This setting is required for **az800l08-vm0** to function as a router, which will route traffic between two spoke virtual networks.

   > **Note**: Now you need to configure the operating system of the **az800l08-vm0** virtual machine to support routing.

1. In the Azure portal, browse back to the **az800l08-vm0** virtual machine page and use the **RunPowerShellScript** from the list of **Run command** operations to run the following command that install the Remote Access Windows Server role.

   ```powershell
   Install-WindowsFeature RemoteAccess -IncludeManagementTools
   ```

   > **Note**: Wait for the confirmation that the command completed successfully.

1. Use the **RunPowerShellScript** again to install the Routing role service by running the following commands:

   ```powershell
   Install-WindowsFeature -Name Routing -IncludeManagementTools -IncludeAllSubFeature
   Install-WindowsFeature -Name "RSAT-RemoteAccess-Powershell"
   Install-RemoteAccess -VpnType RoutingOnly
   Get-NetAdapter | Set-NetIPInterface -Forwarding Enabled
   ```

   > **Note**: Wait for the confirmation that the command completed successfully.

   > **Note**: Now you need to create and configure user-defined routes on the spoke virtual networks.

1. In the Azure portal, browse to the **Route tables** and create a route table with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Location | the name of the Azure region in which you created the virtual networks |
    | Name | **az800l08-rt12** |
    | Propagate gateway routes | **No** |

   > **Note**: Wait for the route table to be created. This should take about 1 minute.

1. Browse to the page of the newly created route table **az800l08-rt12** and add a route with the following settings:

    | Setting | Value |
    | --- | --- |
    | Route name | **az800l08-route-vnet1-to-vnet2** |
    | Address prefix | **10.82.0.0/20** |
    | Next hop type | **Virtual appliance** |
    | Next hop address | **10.80.0.4** |

    > **Note**: **10.80.0.4** represents the private IP address of **az800l08-vm0**. 

1. On the **az800l08-rt12** route table page, associate the route table **az800l08-rt12** with the following subnet:

    | Setting | Value |
    | --- | --- |
    | Virtual network | **az800l08-vnet1** |
    | Subnet | **subnet0** |

1. Browse back to **Route tables** page and create another route table with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Region | the name of the Azure region in which you created the virtual networks |
    | Name | **az800l08-rt21** |
    | Propagate gateway routes | **No** |

   > **Note**: Wait for the route table to be created. This should take about 3 minutes.

1. Browse to the **az800l08-rt21** route table page and add a route with the following settings:

    | Setting | Value |
    | --- | --- |
    | Route name | **az800l08-route-vnet2-to-vnet1** |
    | Address prefix | **10.81.0.0/20** |
    | Next hop type | **Virtual appliance** |
    | Next hop address | **10.80.0.4** |

1. On the **az800l08-rt21** route table page, associate the route table **az800l08-rt21** with the following subnet:

    | Setting | Value |
    | --- | --- |
    | Virtual network | **az800l08-vnet2** |
    | Subnet | **subnet0** |

1. In the Azure portal, browse back to the **Network Watcher - Connection troubleshoot** page and initiate a check with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Source type | **Virtual machine** |
    | Virtual machine | **az800l08-vm1** |
    | Destination | **Specify manually** |
    | URI, FQDN or IPv4 | **10.82.0.4** |
    | Protocol | **TCP** |
    | Destination Port | **3389** |

1. Wait until the results of the connectivity check are returned. Verify that the status is **Reachable**. Review the network path and note that the traffic was routed via **10.80.0.4**, assigned to the **az800l08-nic0** network adapter. 

    > **Note**: This is expected because the traffic between spoke virtual networks is now routed via the virtual machine located in the hub virtual network, which functions as a router.


### Exercise 2: Implement DNS name resolution in Azure

### Scenario

With the custom routing successfully tested, now it's time to implement DNS name resolution for Azure virtual machines between virtual networks by using Azure private DNS zones and evaluate the use of Azure DNS zones for external name resolution.

The main tasks for this exercise are as follows:

1. Configure Azure private DNS name resolution
1. Validate Azure private DNS name resolution
1. Configure Azure public DNS name resolution
1. Validate Azure public DNS name resolution

#### Task 1: Configure Azure private DNS name resolution

In this task, you will configure DNS name resolution between virtual networks by using an Azure private DNS zone.

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, browse to the **Private DNS zones** page. 
1. Create a private DNS zone with the following settings:

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | the name of a new resource group **AZ800-L0802-RG** |
    | Name | **contoso.org** |
    | Resource group location | the same Azure region into which you deploy resources in the previous exercise of this lab |

    >**Note**: Wait for the private DNS zone to be created. This should take about 2 minutes.

1. Browse to the **contoso.org** DNS private zone page.
1. On the **contoso.org** private DNS zone page, add a virtual network link to the first virtual network you created in the previous exercise with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Link name | **az800l08-vnet0-link** |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Virtual network | **az800l08-vnet0 (AZ800-L0801-RG)** |
    | Enable auto registration | selected |

    >**Note:** Wait for the virtual network link to be created. This should take less than 1 minute.

1. Repeat the previous step to create virtual network links (with auto registration enabled) named **az800l08-vnet1-link** and **az800l08-vnet2-link** for the virtual networks **az800l08-vnet1** and **az800l08-vnet2**, respectively.
1. On the **contoso.org** private DNS zone page, browse to the **Overview** pane of the **contoso.org** private DNS zone page, review the listing of DNS record sets and verify that the **A** records of **az800l08-vm0**, **az800l08-vm1**, and **az800l08-vm2** appear in the list as **Auto registered**.

    >**Note:** You might need to wait a few minutes and refresh the page if the record sets are not listed.

#### Task 2: Validate Azure private DNS name resolution

In this task, you will validate Azure private DNS name resolution.

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, browse back to the **Network Watcher - Connection troubleshoot** page.
1. Initiate a check with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Source type | **Virtual machine** |
    | Virtual machine | **az800l08-vm1** |
    | Destination | **Specify manually** |
    | URI, FQDN or IPv4 | **az800l08-vm2.contoso.org** |
    | Preferred IP Version | **IPv4** |
    | Protocol | **TCP** |
    | Destination Port | **3389** |

1. Wait until the results of the connectivity check are returned. Verify that the status is **Reachable**. 

    > **Note**: This is expected because the target fully qualified domain name (FQDN) is resolvable via Azure private DNS zone. 

#### Task 3: Configure Azure public DNS name resolution

In this task, you will configure external DNS name resolution by using Azure public DNS zones.

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, open a new tab and browse to `https://www.godaddy.com/domains/domain-name-search`.
1. Use the domain name search to identify a domain name which is not currently in use.
1. On **SEA-ADM1**, switch to the Microsoft Edge tab displaying the Azure portal and browse to the **DNS zones** page.
1. Create a DNS zone with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource Group | **AZ800-L0802-RG** |
    | Name | the DNS domain name you identified earlier in this task |

    >**Note**: Wait for the DNS zone to be created. This should take about 1 minute.

1. Browse to the page of the newly created DNS zone.
1. Add a record set with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Name | **www** |
    | Type | **A** |
    | Alias record set | **No** |
    | TTL | **1** |
    | TTL unit | **Hours** |
    | IP address | 20.30.40.50 |

    >**Note**: The IP address and the corresponding name are entirely arbitrary. They are meant to provide a very simple example illustrating implementing public DNS records, rather than emulate a real world scenario, which would require purchasing a namespace from a DNS registrar. 

1. On the DNS zone page, identify the full name of **Name server 1**.

    >**Note**: Record the full name of **Name server 1**. You will need it in the next task.

#### Task 4: Validate Azure public DNS name resolution

In this task, you will validate external DNS name resolution by using Azure public DNS zones.

1. On **SEA-ADM1**, on the **Start** menu, select **Windows PowerShell**.
1. In the **Windows PowerShell** console, run the following command to test the external name resolution of the **www** DNS record set in the newly created DNS zone (replace the placeholder `<Name server 1>` with the name of **Name server 1** you noted earlier in this task and the `<domain name>` placeholder with the name of the DNS domain you created earlier in this task):

   ```powershell
   nslookup www.<domain name> <Name server 1>
   ```

1. Verify that the output of the command includes the public IP address of **20.30.40.50**.

    >**Note**: The name resolution works as expected because the **nslookup** command allows you to specify the IP address of the DNS server to query for a record (which, in this case, is `<Name server 1>`. For the name resolution to work when querying any publicly accessible DNS server, you would need to register the domain name with a DNS registrar and configure the name servers listed on the public DNS zone page in the Azure portal as authoritative for the namespace corresponding to that domain.

## Exercise 3: Deprovisioning the Azure environment

#### Task 1: Start a PowerShell session in Cloud Shell

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal.
1. From the Azure portal, open a PowerShell session in the Cloud Shell pane.

#### Task 2: Identify all Azure resources provisioned in the lab

1. From the Cloud Shell pane, run the following command to list all resource groups created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ800-L08*'
   ```

1. Run the following command to delete all resource groups you created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ800-L08*' | Remove-AzResourceGroup -Force -AsJob
   ```

   >**Note**: The command executes asynchronously (as determined by the *-AsJob* parameter), so while you'll be able to run another PowerShell command immediately afterwards within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.

### Results

After completing this lab, you will have:

- Provisioned the lab environment.
- Configured the hub and spoke network topology.
- Tested transitivity of virtual network peering.
- Configured routing in the hub and spoke topology.
- Configured Azure DNS for internal name resolution.
- Configured Azure DNS for external name resolution.
