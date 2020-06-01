<#
    .Example
    $BackupPath = Read-Host -Prompt "Please provide full path to GPO backups"
    .\Import-GPO.ps1 -BackupPath $BackupPath -Verbose

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)][string] $BackupPath,
    [string] $GPOMigrationTable
)

$backupList = Get-ChildItem -Path $BackupPath
Set-Location $BackupPath
$location = Get-Location
foreach ($item in $backupList) {
    $backupID = $null
    $xmlFilePath = $null
    $gpoName = $null
    $backupID = $item.name -replace "{", "" -replace "}", ""
    $xmlFilePath = ".\$($item.name)\gpreport.xml"
    [xml]$xmlFile = Get-Content -Path $xmlFilePath
    $gpoName = $xmlFile.GPO.Name
    Write-Verbose "Importing new GPO '$gpoName' with GUID '$backupID'"
    Write-Verbose "Please remember to update proper groups in GPO settings"
    if ($GPOMigrationTable -ne $null) {
        Import-GPO -BackupId $backupID -TargetName $gpoName -Path $BackupPath -CreateIfNeeded
    }
    else {
        Import-GPO -BackupId $backupID -TargetName $gpoName -Path $BackupPath -MigrationTable $GPOMigrationTable -CreateIfNeeded
    }
    Set-Location $location

}
