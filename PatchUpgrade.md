# SharePoint patch install approach

1.    Note current build version (Get-SPFarm).BuildVersion
2.    Before installing the binaries turn off and disable services if running as per each VM role, note down services stopped
& disabled as per each VMs roles

    # Before installing the bits
       * NET STOP SPTimerV4
       * NET STOP SPAdminV4
       * NET STOP SPTraceV4
       * NET STOP OSearch15  
       * NET STOP SPSearchHostController
       * NET STOP IISADMIN
       * NET STOP AppFabricCachingService
    
    Set-Service -Name "SPTimerV4" -startuptype Disabled 
    Set-Service -Name "SPadminV4" -startuptype Disabled
    Set-Service -Name "SPTraceV4" -startuptype Disabled 
    Set-Service -Name "OSearch15" -startuptype Disabled 
    Set-Service -Name "SPSearchHostController" -startuptype Disabled 
    Set-Service -Name "IISADMIN" -startuptype Disabled 
    Set-Service -Name "AppFabricCachingService" -startuptype Disabled 

    Pause Search Service application on server hosting search components 

    $ssa=Get-SPEnterpriseSearchServiceApplication 
    Suspend-SPEnterpriseSearchServiceApplication -Identity $ssa

3. Install April 2019 CU  binaries in multiple batches one VM at a time to ensure availability of farm.
```
    Batch 1  –  WSP01, WSP07, WSP09 – Weekdays
    Batch 2  –  WSP02, WSP08, WSP10 – Weekdays
    Batch 3  –  WSP03, WSP05 – Weekend
    Batch 4  –  WSP04, WSP06 – Weekend
 ```

4.	After installation of binaries turn on and enable services if they were disabled in step 2, refer list created in step 2

    Set-Service -Name "SPTimerV4" -startuptype Automatic
    Set-Service -Name "SPadminv4" -startuptype Automatic 
    Set-Service -Name "OSearch15" -startuptype Automatic
    Set-Service -Name "SPSearchHostController" -startuptype Automatic
    Set-Service -Name "IISADMIN" -startuptype Automatic
    Set-Service -Name "AppFabricCachingService" -startuptype Automatic
    Set-Service -Name "SPTraceV4" -startuptype Automatic

    NET  Start SPTraceV4
    NET  Start AppFabricCachingService
    NET Start IISADMIN 
    NET Start SPSearchHostController
    NET Start OSearch15 
    NET Start SPAdminv4
    NET Start SPTimerV4
    NET Start W3svc

Verify that all Search components become active after the update by typing the following command at the PowerShell command prompt, Rerun the command until no Search components are listed in the output
Get-SPEnterpriseSearchStatus -SearchApplication $ssa | where {$_.State -ne "Active"} | fl

# Resume Search Service application on server hosting search components
Resume-SPEnterpriseSearchServiceApplication -Identity $ssa

# After an update you may no longer have proper registry key or file system permissions, in that case run the following command
Initialize-SPResourceSecurity


5.	Restart VM to complete binaries installation

6.	Run Test-SPContentDatabase for all content database latest copies on UAT farm. This cmdlet can be issued against a content database currently attached to the farm, or a content database that is not connected to the farm. Cmdlet does not change any of the data or structure of the content database, but can cause load on the database while the checks are in progress, which could temporarily block use of the content This cmdlet should only be used against a content database that is currently under low or no usage. 

7.	Note the upgrade blockers listed in step 5, remediate upgrade blockers on UAT farm first before running remediation on PROD farm.

8.	Clear the SharePoint Configuration Cache on all SP VMs immediately before running upgrade commands and wizard. 
a.	Stop  search content source crawls 
b.	Stop user profile synchronization.

9.	Run Upgrade-SPContentDatabase with -UseSnapshot parameters. During upgrade, users see a ready-only version of the database, which is the snapshot. After upgrade users see upgraded content. The existing connections to the content database will be set to use the snapshot for the duration of the upgrade and then switched back after successful completion of upgrade. A failed upgrade reverts the database to its state when the snapshot was taken.

10.	Run the SharePoint configuration wizard UI to upgrade all the SharePoint configuration and service databases and VMs in the batches as given in step 1, only during weekend. Choose the first VM to run configuration wizard UI hosting the Central Admin site. During the configuration wizard run on first VM farm databases are upgraded, this would cause farm downtime. Subsequent run of configuration wizard UI on remaining VMs should not cause an entire farm downtime but only the VM running configuration wizard be unavailable.

11.	Validate farm services and site collection available post completion of upgrade activity. Note upgraded build version (Get-SPFarm).BuildVersion


## Note:  
1.	Increasing CPU and RAM on SP farm VM during binaries installation can improve time required to install binaries
2.	Increasing CPU and RAM on SQL VM during configuration wizard upgrade action can improve time required to upgrade databases
3.	Antivirus, Antimalware, monitoring and logging applications running in background can lead to longer CU installation. Evaluate the option of turning off these services during the binary installation to improve time required for installation. 
4.	Validate downtime and service disruptions that can happen on UAT environment before using this approach on PROD.
5.	Open MS support ticket to have support for troubleshooting issues.

## Troubleshooting

Remove from AG
ALTER AVAILABILITY GROUP [AGName] REMOVE DATABASE [DB_Name];

Upgrade Db Powershell
Upgrade-SPContentDatabase DB_Name -UseSnapshot -Verbose

Add Db to AG
ALTER AVAILABILITY GROUP [AGName] ADD DATABASE [DB_Name];

Turn on HDR on Secondary DB
ALTER DATABASE [DB_Name] SET HADR AVAILABILITY GROUP = [AGName];

sp_who2
kill 84
ALTER DATABASE [DB_Name] SET MULTI_USER;
ALTER DATABASE [DB_Name] SET READ_WRITE With No_Wait;

Reference:
https://blog.stefan-gossner.com/2016/04/29/sharepoint-2016-zero-downtime-patching-demystified/
https://docs.microsoft.com/en-us/SharePoint/upgrade-and-update/install-a-software-update
