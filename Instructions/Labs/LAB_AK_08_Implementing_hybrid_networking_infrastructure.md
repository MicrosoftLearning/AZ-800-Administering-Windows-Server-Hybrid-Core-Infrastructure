---
lab:
    title: 'Lab: Implementing Windows Server IaaS VM networking'
    type: 'Answer Key'
    module: 'Module 8: Implementing Windows Server IaaS VM networking'
---

# Lab answer key: Implementing hybrid networking infrastructure

**Note:** An **[interactive lab simulation](https://mslabs.cloudguides.com/guides/AZ-800%20Lab%20Simulation%20-%20Implementing%20hybrid%20networking%20infrastructure)** is available that allows you to click through this lab at your own pace. You may find slight differences between the interactive simulation and the hosted lab, but the core concepts and ideas being demonstrated are the same. 

### Exercise 1: Implement virtual network routing in Azure

#### Task 1: Provision lab infrastructure resources

1. Connect to **SEA-ADM1**, and then, if needed, sign in as **CONTOSO\Administrator** with a password of **Pa55w.rd**.
1. On **SEA-ADM1**, start Microsoft Edge, go to the Azure portal at `https://portal.azure.com`, and sign in by using the credentials of a user account with the Owner role in the subscription you'll be using in this lab.
1. In the Azure portal, open the Cloud Shell pane by selecting the toolbar icon next to the search text box.
1. If prompted to select either **Bash** or **PowerShell**, select **PowerShell**.

   >**Note**: If this is the first time you are starting Cloud Shell and you are presented with the **You have no storage mounted** message, select the subscription you are using in this lab, and then select **Create storage**.

1. In the toolbar of the Cloud Shell pane, select the **Upload/Download files** icon, in the drop-down menu, select **Upload**, and upload the files **C:\\Labfiles\\Lab08\\L08-rg_template.json** and **C:\\Labfiles\\Lab08\\L08-rg_template.parameters.json** into the Cloud Shell home directory.
1. From the Cloud Shell pane, run the following commands to create the first resource group that will be hosting the lab environment (replace the `<Azure_region>` placeholder with the name of an Azure region you intend to use for the deployment):

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

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, open another tab and browse to the Azure portal at `https://portal.azure.com`.
1. In the Azure portal, in the **Search resources, services, and docs** text box in the toolbar, search for and select **Virtual networks**.
1. In the list of virtual networks, select **az800l08-vnet0**.
1. On the **az800l08-vnet0** virtual network page, in the **Settings** section, select **Peerings**, and then select **+ Add**.
1. Specify the following settings (leave others with their default values), and then select **Add**:

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

1. On the **az800l08-vnet0** virtual network page, in the **Settings** section, select **Peerings**, and then select **+ Add**.
1. Specify the following settings (leave others with their default values), and then select **Add**:

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

>**Note**: Before you start this task, make sure that the script you invoked in the first task of this exercise completed successfully.

1. In the Azure portal, search for and select **Network Watcher**.
1. On the **Network Watcher** page, browse to the **Connection troubleshoot**.
1. On the **Network Watcher - Connection troubleshoot** page, initiate a check with the following settings (leave others with their default values):

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

1. Select **Check** and wait until results of the connectivity check are returned. Verify that the status is **Reachable**. Review the network path and note that the connection was direct, with no intermediate hops in between the VMs.

    > **Note**: This is expected because the hub virtual network is peered directly with the first spoke virtual network.

1. On the **Network Watcher - Connection troubleshoot** page, initiate a check with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Source type | **Virtual machine** |
    | Virtual machine | **az800l08-vm0** |
    | Destination | **Specify manually** |
    | URI, FQDN, or IPv4 | **10.82.0.4** |
    | Protocol | **TCP** |
    | Destination Port | **3389** |

    > **Note**: **10.82.0.4** represents the private IP address of **az800l08-vm2**. 

1. Select **Check** and wait until results of the connectivity check are returned. Verify that the status is **Reachable**. Review the network path and note that the connection was direct, with no intermediate hops in between the VMs.

    > **Note**: This is expected because the hub virtual network is peered directly with the second spoke virtual network.

1. On the **Network Watcher - Connection troubleshoot** page, specify the following settings (leave others with their default values) and initiate another check:

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

1. Select **Check** and wait until results of the connectivity check are returned. Note that the status is **Unreachable**.

    > **Note**: This is expected because the two spoke virtual networks are not peered with each other and virtual network peering is not transitive.

#### Task 4: Configure routing in the hub and spoke topology

1. In the Azure portal, search and select **Virtual machines**.
1. On the **Virtual machines** page, in the list of virtual machines, select **az800l08-vm0**.
1. On the **az800l08-vm0** virtual machine page, in the **Settings** section, select **Networking**.
1. Select the **az800l08-nic0** link next to the **Network interface** label, and then, on the **az800l08-nic0** network interface page, in the **Settings** section, select **IP configurations**.
1. Set **IP forwarding** to **Enabled** and select **Save** to save the change.

   > **Note**: This setting is required in order for **az800l08-vm0** to function as a router, which will route traffic between two spoke virtual networks.

   > **Note**: Now you need to configure the operating system of the **az800l08-vm0** virtual machine to support routing.

1. In the Azure portal, browse back to the **az800l08-vm0** Azure virtual machine page.
1. On the **az800l08-vm0** page, in the **Operations** section, select **Run command**, and then, in the list of commands, select **RunPowerShellScript**.
1. On the **Run Command Script** page, enter the following command, and then select **Run** to install the Remote Access Windows Server role.

   ```powershell
   Install-WindowsFeature RemoteAccess -IncludeManagementTools
   ```

   > **Note**: Wait for the confirmation that the command completed successfully.

1. On the **Run Command Script** page, in the **PowerShell script** section, replace the previously entered command with the following commands, and then select **Run** to install the Routing role service.

   ```powershell
   Install-WindowsFeature -Name Routing -IncludeManagementTools -IncludeAllSubFeature
   Install-WindowsFeature -Name "RSAT-RemoteAccess-Powershell"
   Install-RemoteAccess -VpnType RoutingOnly
   Get-NetAdapter | Set-NetIPInterface -Forwarding Enabled
   ```

   > **Note**: Wait for the confirmation that the command completed successfully.

   > **Note**: Now you need to create and configure user-defined routes on the spoke virtual networks.

1. In the Azure portal, in the **Search resources, services, and docs** text box in the toolbar, search for and select **Route tables**, and then, on the **Route tables** page, select **+ Create**.
1. Create a route table with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Location | the name of the Azure region in which you created the virtual networks |
    | Name | **az800l08-rt12** |
    | Propagate gateway routes | **No** |

1. Select **Review + create**, and then select **Create**.

   > **Note**: Wait for the route table to be created. This should take about 1 minute.

1. Select **Go to resource**.
1. On the **az800l08-rt12** route table page, in the **Settings** section, select **Routes**, and then select **+ Add**.
1. Add a new route with the following settings:

    | Setting | Value |
    | --- | --- |
    | Route name | **az800l08-route-vnet1-to-vnet2** |
    | Address prefix destination | **IP Addresses** |
    | Destination IP Address/CIDR ranges | **10.82.0.0/20** |
    | Next hop type | **Virtual appliance** |
    | Next hop address | **10.80.0.4** |

    > **Note**: **10.80.0.4** represents the private IP address of **az800l08-vm0**. 

1. Select **Add**.
1. Back on the **az800l08-rt12** route table page, in the **Settings** section, select **Subnets**, and then select **+ Associate**.
1. Associate the route table **az800l08-rt12** with the following subnet:

    | Setting | Value |
    | --- | --- |
    | Virtual network | **az800l08-vnet1** |
    | Subnet | **subnet0** |

1. Select **OK**.
1. Browse back to **Route tables** page and select **+ Create**.
1. Create a route table with the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | **AZ800-L0801-RG** |
    | Region | the name of the Azure region in which you created the virtual networks |
    | Name | **az800l08-rt21** |
    | Propagate gateway routes | **No** |

1. Select **Review + create**, and then select **Create**.

   > **Note**: Wait for the route table to be created. This should take about 3 minutes.

1. Select **Go to resource**.
1. On the **az800l08-rt21** route table page, in the **Settings** section, select **Routes**, and then select **+ Add**.
1. Add a new route with the following settings:

    | Setting | Value |
    | --- | --- |
    | Route name | **az800l08-route-vnet2-to-vnet1** |
    | Address prefix | **10.81.0.0/20** |
    | Next hop type | **Virtual appliance** |
    | Next hop address | **10.80.0.4** |

1. Select **Add**.
1. Back on the **az800l08-rt21** route table page, in the **Settings** section, select **Subnets**, and then select **+ Associate**.
1. Associate the route table **az800l08-rt21** with the following subnet:

    | Setting | Value |
    | --- | --- |
    | Virtual network | **az800l08-vnet2** |
    | Subnet | **subnet0** |

1. Select **OK**.
1. In the Azure portal, browse back to the **Network Watcher - Connection troubleshoot** page.
1. On the **Network Watcher - Connection troubleshoot** page, initiate a check with the following settings (leave others with their default values):

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

1. Select **Check** and wait until results of the connectivity check are returned. Verify that the status is **Reachable**. Review the network path and note that the traffic was routed via **10.80.0.4**, assigned to the **az800l08-nic0** network adapter. 

    > **Note**: This is expected because the traffic between spoke virtual networks is now routed via the virtual machine located in the hub virtual network, which functions as a router.


### Exercise 2: Implement DNS name resolution in Azure

#### Task 1: Configure Azure private DNS name resolution

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, in the **Search resources, services, and docs** text box in the toolbar, search for and select **Private DNS zones**, and then, on the **Private DNS zones** page, select **+ Create**.
1. Create a private DNS zone with the following settings:

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource group | the name of a new resource group **AZ800-L0802-RG** |
    | Name | **contoso.org** |
    | Resource group location | the same Azure region into which you deploy resources in the previous exercise of this lab |

1. Select **Review and Create**, and then select **Create**.

    >**Note**: Wait for the private DNS zone to be created. This should take about 2 minutes.

1. Select **Go to resource** to open the **contoso.org** DNS private zone page.
1. On the **contoso.org** private DNS zone page, in the **Settings** section, select **Virtual network links**.
1. On the **contoso.org \| Virtual network links** page, select **+ Add**, specify the following settings (leave others with their default values), and select **OK** to create a virtual network link for the first virtual network you created in the previous exercise:

    | Setting | Value |
    | --- | --- |
    | Link name | **az800l08-vnet0-link** |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Virtual network | **az800l08-vnet0 (AZ800-L0801-RG)** |
    | Enable auto registration | selected |

    >**Note:** Wait for the virtual network link to be created. This should take less than 1 minute.

1. Repeat the previous step to create virtual network links (with auto registration enabled) named **az800l08-vnet1-link** and **az800l08-vnet2-link** for the virtual networks **az800l08-vnet1** and **az800l08-vnet2**, respectively.
1. On the **contoso.org** private DNS zone page, in the vertical menu on the left, select **Overview**.
1. In the **Overview** section of the **contoso.org** private DNS zone page, review the listing of DNS record sets and verify that the **A** records of **az800l08-vm0**, **az800l08-vm1**, and **az800l08-vm2** appear in the list as **Auto registered**.

    >**Note:** You might need to wait a few minutes and refresh the page if the record sets are not listed.

#### Task 2: Validate Azure private DNS name resolution

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, browse back to the **Network Watcher - Connection troubleshoot** page.
1. On the **Network Watcher - Connection troubleshoot** page, initiate a check with the following settings (leave others with their default values):

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

1. Select **Check** and wait until the results of the connectivity check are returned. Verify that the status is **Reachable**. 

    > **Note**: This is expected because the target fully qualified domain name (FQDN) is resolvable via the Azure private DNS zone. 

#### Task 3: Configure Azure public DNS name resolution

1. On **SEA-ADM1**, in the Microsoft Edge window displaying the Azure portal, open a new tab and browse to `https://www.godaddy.com/domains/domain-name-search`.
1. Use the domain name search to identify a domain name that is not currently in use.
1. On **SEA-ADM1**, switch to the Microsoft Edge tab displaying the Azure portal, in the **Search resources, services, and docs** text box in the toolbar, search for and select **DNS zones**, and then, on the **DNS zones** page, select **+ Create**.
1. On the **Create DNS zone** page, specify the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Subscription | the name of the Azure subscription you are using in this lab |
    | Resource Group | **AZ800-L0802-RG** |
    | Name | the DNS domain name you identified earlier in this task |

1. Select **Review + create**, and then select **Create**.

    >**Note**: Wait for the DNS zone to be created. This should take about 1 minute.

1. Select **Go to resource** to open the page of the newly created DNS zone.
1. On the DNS zone page, select **+ Record set**.
1. In the Add a record set pane, specify the following settings (leave others with their default values):

    | Setting | Value |
    | --- | --- |
    | Name | **www** |
    | Type | **A** |
    | Alias record set | **No** |
    | TTL | **1** |
    | TTL unit | **Hours** |
    | IP address | 20.30.40.50 |

    >**Note**: The IP address and the corresponding name are entirely arbitrary. They are meant to provide a very simple example illustrating implementing public DNS records, rather than emulate a real world scenario, which would require purchasing a namespace from a DNS registrar. 

1. Select **OK**
1. On the DNS zone page, identify the full name of **Name server 1**.

    >**Note**: Record the full name of **Name server 1**. You will need it in the next task.

#### Task 4: Validate Azure public DNS name resolution

1. On **SEA-ADM1**, on the **Start** menu, select **Windows PowerShell**.
1. In the **Windows PowerShell** console, enter the following command, and then press Enter to test external name resolution of the **www** DNS record set in the newly created DNS zone (replace the placeholder `<Name server 1>` with the name of **Name server 1** you noted earlier in this task and the `<domain name>` placeholder with the name of the DNS domain you created earlier in this task):

   ```powershell
   nslookup www.<domain name> <Name server 1>
   ```

1. Verify that the output of the command includes the public IP address of **20.30.40.50**.

    >**Note**: The name resolution works as expected because the **nslookup** command allows you to specify the IP address of the DNS server to query for a record (which, in this case, is `<Name server 1>`). For the name resolution to work when querying any publicly accessible DNS server, you would need to register the domain name with a DNS registrar and configure the name servers listed on the public DNS zone page in the Azure portal as authoritative for the namespace corresponding to that domain.

## Exercise 3: Deprovisioning the Azure environment

#### Task 1: Start a PowerShell session in Cloud Shell

1. On **SEA-ADM1**, switch to the Microsoft Edge window displaying the Azure portal.
1. In the Microsoft Edge window displaying the Azure portal, open the Cloud Shell pane by selecting the Cloud Shell icon.

#### Task 2: Identify all Azure resources provisioned in the lab

1. From the Cloud Shell page, run the following command to list all the resource groups created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ800-L08*'
   ```

1. Run the following command to delete all resource groups you created throughout this lab:

   ```powershell
   Get-AzResourceGroup -Name 'AZ800-L08*' | Remove-AzResourceGroup -Force -AsJob
   ```

   >**Note**: The command executes asynchronously (as determined by the *-AsJob* parameter), so while you'll be able to run another PowerShell command immediately afterwards within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.
