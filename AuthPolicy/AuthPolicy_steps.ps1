Throw "this is not a robust file" 
$location = Get-Location
$oldVerbosePreference = $VerbosePreference
$VerbosePreference = 'Continue'
Set-Location C:\Tools\AuthPolicy
 #region import GPO
    $backupPath = "$ScriptsLocation\GPO Backup"
    $dnsRoot = (get-addomain).DNSRoot
    $migTable = "gpo_backup_" + $((Get-ADDOmain).NetBIOSName) + ".migtable"
    $migTablePath = "$ScriptsLocation\Scripts\" + $migTable
    Copy-Item -Path $ScriptsLocation\Scripts\gpo_backup.migtable -Destination $migTablePath
    ((Get-Content -path $migTablePath  -Raw) -replace 'CHANGEME', $dnsRoot )| Set-Content -Path $migTablePath 
    $gPOMigrationTable = (Get-ChildItem -Path "$ScriptsLocation\Scripts\" -Filter "$migTable").fullname
    .$ScriptsLocation\Scripts\Import-GPO.ps1 -BackupPath $backupPath -GPOMigrationTable $gPOMigrationTable -Verbose
#endregion

#region Link gpo
$GpoLinks = @(
    $(New-Object PSObject -Property @{ Name = "KDC Support for claims"; OU = "OU=Domain Controllers"; Order = 2 ;LinkEnabled = 'YES'}),
    $(New-Object PSObject -Property @{ Name = "Kerberos client support for claims" ; OU = ""; Order = 2 ;LinkEnabled = 'YES'})
)
.$ScriptsLocation\Scripts\Link-GpoToOU.ps1 -GpoLinks $GpoLinks -Verbose
Set-Location $location
#endregion


#region AuthPolicies
.$ScriptsLocation\Scripts\New-AuthenticationPolicy.ps1 -PolicyName 'Tier0PAW' -ComputersGroupName 'Tier0PAWComputers' -UsersGroupName 'Domain Admins' -OUsToInclude  @("OU=Tier0,OU=Admin","OU=Domain Controllers") -UserTGTLifetimeMins 121
.$ScriptsLocation\Scripts\New-AuthenticationPolicy.ps1 -PolicyName 'Tier1PAW' -ComputersGroupName 'Tier1PAWComputers' -UsersGroupName 'Tier1PAWUser' -OUsToInclude  @("OU=Tier1,OU=Admin","OU=Tier 1 Servers") -UserTGTLifetimeMins 121
.$ScriptsLocation\Scripts\New-AuthenticationPolicy.ps1 -PolicyName 'Tier0SyncServers' -ComputersGroupName 'Tier0SyncServers' -UsersGroupName 'Tier0ReplicationMaintenance' -OUsToInclude  @("OU=Synchronisation,OU=Tier0 Servers,OU=Tier0,OU=Admin","OU=Domain Controllers") -UserTGTLifetimeMins 121
#endRegion
 
