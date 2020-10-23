###########################################################################################
# Get Workflow Usage
# Interactive logon
###########################################################################################

Import-Module SharePointPnPPowerShellOnline -WarningAction SilentlyContinue


##########################################################################################
# Custom input values
##########################################################################################
$inputFile = $PSScriptRoot + "\sites.csv"
$outputFile = $PSScriptRoot + "\workflowusage.csv"
$siteError = $PSScriptRoot + "\siteerror.csv"
$listError = $PSScriptRoot + "\listerror.csv"  
$clientId =""  # change here
$clientSecret = ""  # change here
##########################################################################################

$siteUrl = "" # Keep blank
$exclusionList = @("Access Requests","App Packages","appdata","appfiles","Apps in Testing","Apps for SharePoint","Hub Settings","Channel Settings","Cache Profiles","Composed Looks","Content and Structure Reports","Content type publishing error log","Converted Forms",
"Device Channels","Form Templates","fpdatasources","Get started with Apps for Office and SharePoint","List Template Gallery", "Long Running Operation Status","Maintenance Log Library", "Images", "site collection images"
,"Master Docs","Master Page Gallery","MicroFeed","NintexFormXml","Quick Deploy Items","Relationships List","Reusable Content","Reporting Metadata", "Reporting Templates", "Search Config List","Site Assets","Preservation Hold Library",
"Site Pages", "Solution Gallery","Style Library","Suggested Content Browser Locations","Theme Gallery", "TaxonomyHiddenList","User Information List","Web Part Gallery","wfpub","wfsvc","Workflow History","Workflow Tasks", "Pages","AppPages")

try {
    $fcheck = Test-Path $outputFile
    if(!$fcheck){
    New-Item -Path $outputFile -ItemType File
    }
    else {
        Clear-Content $outputFile
    }
    Add-Content $outputFile "Site,List,WF Name,Last Used"

    $fcheck = Test-Path $siteError
    if(!$fcheck){
    New-Item -Path $siteError -ItemType File
    }
    else {
        Clear-Content $siteError
    }
    Add-Content $siteError "Site,Error Message"

    $fcheck = Test-Path $listError
    if(!$fcheck){
    New-Item -Path $listError -ItemType File
    }
    else {
        Clear-Content $listError
    }
    Add-Content $listError "Site,List,Error Message"

    $sites = Import-Csv $inputFile
    $sites |
    ForEach-Object {
        $siteUrl = $_.Url
        try{
            Connect-PnPOnline  $siteUrl -ClientId $clientId -ClientSecret $clientSecret
            Write-Host $siteUrl
            # site workflows
            Get-PnPWeb -Includes ("WorkflowAssociations") |
            ForEach-Object {
                if(0 -ne $_.WorkflowAssociations.Count){
                    $_.WorkflowAssociations | 
                    ForEach-Object{
                        param($asocs =$_)
                        Write-Host $asocs.HistoryListTitle
                        if("NintexWorkflowHistory" -ne  $asocs.HistoryListTitle){
                            $wfname = $asocs.Name
                            # Workflow histroy Item since 1-Jan-2020
                            $query = "<View><Query><Where><And><Eq><FieldRef Name='WorkflowAssociation'/><Value Type='Text'>{" + $asocs.Id + "}</Value></Eq><Gt><FieldRef Name='Occurred'/><Value Type='DateTime'>2020-01-01T01:01:01Z</Value></Gt></And></Where><OrderBy><FieldRef Name='ID' Ascending='FALSE' /></OrderBy></Query><RowLimit Paged='true'>5</RowLimit></View>"
                            Get-PnPListItem -List $asocs.HistoryListTitle -Query $query |
                            Select-Object -First 1 |
                            ForEach-Object {
                                Add-Content $outputFile ($siteUrl + ",Site Workflow," + $wfname.Replace(","," ") + "," + $_.FieldValues.Occurred.ToLocalTime())
                            }
                        }
                    }       
                }
            }
            # list workflows
            Get-PnPList -Includes ("WorkflowAssociations")  | 
            Where-Object {$exclusionList -notcontains $_.Title} |
            ForEach-Object {
                param($list=$_)
                Write-Host $list.Title
                if(0 -ne $_.WorkflowAssociations.Count){
                    $_.WorkflowAssociations | 
                    ForEach-Object{
                        param($asocs =$_)
                        Write-Host $asocs.HistoryListTitle
                        if("NintexWorkflowHistory" -ne  $asocs.HistoryListTitle){
                            $wfname = $asocs.Name
                            # Workflow histroy Item since 1-Apr-2019
                            $query = "<View><Query><Where><And><Eq><FieldRef Name='WorkflowAssociation'/><Value Type='Text'>{" + $asocs.Id + "}</Value></Eq><Gt><FieldRef Name='Occurred'/><Value Type='DateTime'>2019-04-01T01:01:01Z</Value></Gt></And></Where><OrderBy><FieldRef Name='ID' Ascending='FALSE' /></OrderBy></Query><RowLimit Paged='true'>5</RowLimit></View>"
                            try{
                                Get-PnPListItem -List $asocs.HistoryListTitle -Query $query |
                                Select-Object -First 1 |
                                ForEach-Object {
                                    Add-Content $outputFile ($siteUrl + "," + $list.RootFolder.ServerRelativeUrl + "," + $wfname.Replace(","," ") + "," + $_.FieldValues.Occurred.ToLocalTime())
                                }
                            }catch{
                                Add-Content $listError ($siteUrl + "," + $list.RootFolder.ServerRelativeUrl  + "," +  $error[0].Message)
                            }
                        }
                    }       
                }
            }
        }catch{
            Add-Content $siteError ($siteUrl + "," + $error[0].Message)
        }
    }
}
catch{
        Write-Error $Error[0]
    }
Finally{
    Disconnect-PnPOnline
}
