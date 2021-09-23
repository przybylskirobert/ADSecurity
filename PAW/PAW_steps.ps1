Throw "this is not a robust file" 
$location = Get-Location
Set-Location C:\Tools\PAW

#Region create Groups 
$csv = Read-Host -Prompt "Please provide full path to Admin Groups csv file"
.\Create-Group.ps1 -CSVfile $csv -Verbose
$csv = Read-Host -Prompt "Please provide full path to Standard Groups csv file"
.\Create-Group.ps1 -CSVfile $csv -Verbose
#endRegion

#Region create Users
$csv = Read-Host -Prompt "Please provide full path to Users csv file"
.\Create-User.ps1 -CSVfile $csv -password zaq12WSXcde3 -Verbose
#endRegion

#region import GPO
    Throw "Please update migration table file"
    $BackupPath = Read-Host -Prompt "Please provide full path to GPO backups"
    $GPOMigrationTable = Read-Host -Prompt "Please provide full path to GPO Migration Table"
    .\Import-GPO.ps1 -BackupPath $BackupPath -GPOMigrationTable $GPOMigrationTable -Verbose
    Set-Location C:\Tools\PAW
    Write-Host "!!!!!!!!!!!!!!!! Please copy proxy.pac file to the Sysvol\Scripts\" -ForegroundColor Green
#endregion

#region Link gpo
    $GpoLinks = @(
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Devices,OU=Tier0,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Devices,OU=Tier1,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Devices,OU=Tier2,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Tier 1 Servers"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Workstations"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Restrict Quarantine Logon" ; OU = "OU=Quarantine"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Tier0 Restrict Server Logon" ; OU = "OU=Devices,OU=Tier0,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Tier1 Restrict Server Logon" ; OU = "OU=Devices,OU=Tier1,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Tier1 Restrict Server Logon" ; OU = "OU=Tier 1 Servers"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Tier2 Restrict Workstation Logon" ; OU = "OU=Devices,OU=Tier2,OU=Admins"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Tier2 Restrict Workstation Logon" ; OU = "OU=Workstations"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Tier0 PAW Configuration - Computer" ; OU = "OU=Devices,OU=Tier0,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Tier0 PAW Configuration - User" ; OU = "OU=Accounts,OU=Tier0,OU=Admin"; Order = 1 ;LinkEnabled = 'No'}),
        $(New-Object PSObject -Property @{ Name = "Tier0 PAW Configuration - User PAC" ; OU = "OU=Accounts,OU=Tier0,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Tier1 PAW Configuration - Computer" ; OU = "OU=Devices,OU=Tier1,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "Tier1 PAW Configuration - User" ; OU = "OU=Accounts,OU=Tier1,OU=Admin"; Order = 1 ;LinkEnabled = 'NO'})
        $(New-Object PSObject -Property @{ Name = "Tier1 PAW Configuration - User PAC" ; OU = "OU=Accounts,OU=Tier1,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'})
    )
    .\Link-GpoToOU.ps1 -GpoLinks $GpoLinks -Verbose
dsa.msc
gpmc.msc
#endregion

#region Setup Computer Objects 
    Get-ADComputer -Identity W10 | Move-ADObject -TargetPath "OU=Quarantine,DC=Azureblog,DC=pl"
    Get-ADComputer -Identity SRV01 | Move-ADObject -TargetPath "OU=Devices,OU=Tier0,OU=Admin,DC=Azureblog,DC=pl"
    Get-ADCOmputer -Identity W10
    Get-ADComputer -Identity SRV01
#endregion

#region Tier0PAWUser on SRV01
    whoami /groups
    net user testuser zaq12WSX /add
    [System.Net.WebProxy]::GetDefaultProxy() | select address
#endregion

#region Tier0PAWMAintenancer on SRV01
    whoami /groups
    net user testuser zaq12WSX /add
    net user testuser
    net user testuser /del
    [System.Net.WebProxy]::GetDefaultProxy() | select address
#endregion

Set-Location $location


