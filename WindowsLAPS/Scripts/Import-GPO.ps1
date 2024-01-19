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

$backupList = Get-ChildItem -Path $BackupPath -Exclude "manifest.xml"
Set-Location $BackupPath
$location = Get-Location
foreach ($item in $backupList){
    $backupID = $null
    $xmlFilePath = $null
    $gpoName = $null
    $backupID = $item.name -replace "{","" -replace "}",""
    $xmlFilePath = ".\$($item.name)\gpreport.xml"
    [xml]$xmlFile = Get-Content -Path $xmlFilePath
    $gpoName = $xmlFile.GPO.Name
    Write-Host "Importing new GPO '$gpoName' with GUID '$backupID'" -ForegroundColor Green
    Write-Host "Please remember to update proper groups in GPO settings" -ForegroundColor Green
    if ($GPOMigrationTable -eq "") {
        Write-Verbose 'Import-GPO -BackupId $backupID -TargetName $gpoName -Path $BackupPath -CreateIfNeeded'
        Import-GPO -BackupId $backupID -TargetName $gpoName -Path $BackupPath -CreateIfNeeded
    }
    else {
        Write-Verbose 'Import-GPO -BackupId $backupID -TargetName $gpoName -Path $BackupPath -MigrationTable $GPOMigrationTable -CreateIfNeeded'
        Import-GPO -BackupId $backupID -TargetName $gpoName -Path $BackupPath -MigrationTable $GPOMigrationTable -CreateIfNeeded
    }    
    Set-Location $location
}