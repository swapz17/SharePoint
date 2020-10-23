# Run PowerShell in Admin mode to install
Install-Module -Name Microsoft.Online.SharePoint.PowerShell

# Load module
Import-Module -Name Microsoft.Online.SharePoint.PowerShell

# Connect to SharePoint online
# Connect-SPOService -Url https://swava-admin.sharepoint.com/

$cred = Get-Credential
Connect-SPOService -Url https://swava-admin.sharepoint.com/ -Credential $cred
