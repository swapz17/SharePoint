 @{
    AllNodes = @(
        @{
            NodeName        = "SP2019"
            RunCentralAdmin = $true
            ServerRole      = "SingleServerFarm"
        },
        @{
            NodeName                    = "*"
            PSDSCAllowPlainTextPassword = $true
            PSDSCAllowDomainUser        = $true
        }
    )
    SharePoint = @{
        Settings = @{
            DatabaseServer = "SP2019"
            BinaryPath     = "C:\Binaries\"
            ProductKey     = ""
        }
    }
}