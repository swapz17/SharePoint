Configuration SP2019Server
{
    $credsSPFarm      = Get-Credential -Credential "contoso\spfarm"
    $credsSPSetup     = Get-Credential -Credential "contoso\spsetup"
    $credsSPServices  = Get-Credential -Credential "contoso\spsvcapp"
    $credsSPSearch    = Get-Credential -Credential "contoso\spsrch"
    $credsSPAdmin     = Get-Credential -Credential "contoso\spadmin"
 
    Import-DscResource -ModuleName "SharePointDSC"  -Moduleversion "3.0.0.0"
     
    Node $AllNodes.NodeName
    {
        SPFarm SharePointFarm
        {
            IsSingleInstance          = "Yes"
            Ensure                    = "Present"
            FarmConfigDatabaseName    = "SP_Config"
            DatabaseServer            = $ConfigurationData.SharePoint.Settings.DatabaseServer
            FarmAccount               = $credsSPFarm
            Passphrase                = $credsSPFarm
            AdminContentDatabaseName  = "SP_Admin"
            RunCentralAdmin           = $Node.RunCentralAdmin
            CentralAdministrationPort = "5000"
            ServerRole                = $Node.ServerRole
            PSDSCRunAsCredential      = $credsSPSetup
        }
 
        if ($node.RunCentralAdmin -eq $true)
        {
            SPManagedAccount SPFarmAccount
            {
                AccountName            = $credsSPFarm.UserName
                Account                = $credsSPFarm
                PSDSCRunAsCredential   = $credsSPSetup
                DependsOn              = "[SPFarm]SharePointFarm"
            }
 
            SPManagedAccount SPServices
            {
                AccountName            = $credsSPServices.UserName
                Account                = $credsSPServices
                PSDSCRunAsCredential   = $credsSPSetup
                DependsOn              = "[SPFarm]SharePointFarm"
            }
 
            SPManagedAccount SPSearch
            {
                AccountName            = $credsSPSearch.UserName
                Account                = $credsSPSearch
                PSDSCRunAsCredential   = $credsSPSetup
                DependsOn              = "[SPFarm]SharePointFarm"
            }
 
            SPManagedAccount SPAdmin
            {
                AccountName            = $credsSPAdmin.UserName
                Account                = $credsSPAdmin
                PSDSCRunAsCredential   = $credsSPSetup
                DependsOn              = "[SPFarm]SharePointFarm"
            }
 
            SPWebApplication Root
            {
                Ensure                 = "Present"
                Name                   = "Root"
                ApplicationPool        = "Portal"
                ApplicationPoolAccount = $credsSPFarm.UserName
                WebAppUrl              = "http://portal.contoso.com"
                DatabaseServer         = $ConfigurationData.SharePoint.Settings.DatabaseServer
                DatabaseName           = "Portal_Content"
                HostHeader             = "portal.contoso.com"
                AllowAnonymous         = $false
                PSDSCRunAsCredential   = $credsSPSetup
                DependsOn              = "[SPManagedAccount]SPFarmAccount"
            }
 
            SPSite RootSite
            {
                Name                     = "Home Site Collection"
                Url                      = "http://portal.contoso.com"
                OwnerAlias               = "contoso\swapz17"
                ContentDatabase          = "Portal_Content"
                Description              = "Home Site Collection"
                Template                 = "STS#3"
                PSDSCRunAsCredential     = $credsSPSetup
                DependsOn                = "[SPWebApplication]Root"
            }
 
        }
    }
}

SP2019Server -ConfigurationData .\SP2019-ConfigData.psd1