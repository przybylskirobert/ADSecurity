Throw "this is not a robust file" 
$location = Get-Location
$dsnAME = (Get-ADDomain).DistinguishedName
$dNC = (Get-ADRootDSE).defaultNamingContext
$domain = $env:USERDNSDOMAIN
$ScriptsLocation =  "C:\Tools\ADSecurity\PAW"
Set-Location $ScriptsLocation

Import-Module ActiveDirectory

#Region create Groups 
    $csv = Read-Host -Prompt "Please provide full path to Admin Groups csv file (without quotation marks)"
    .$ScriptsLocation\Scripts\Create-Group.ps1 -CSVfile $csv -Verbose
    $csv = Read-Host -Prompt "Please provide full path to Standard Groups csv file (without quotation marks)"
    .$ScriptsLocation\Scripts\Create-Group.ps1 -CSVfile $csv -Verbose
#endRegion

#Region create Users
    $csv = Read-Host -Prompt "Please provide full path to Users csv file (without quotation marks)"
    .$ScriptsLocation\Scripts\Create-User.ps1 -CSVfile $csv -password zaq12WSXcde3 -Verbose
#endRegion

#region import GPO
    $backupPath = "$ScriptsLocation\GPO"
    $migTable = "gpo_backup_" + $((Get-ADDOmain).NetBIOSName) + ".migtable"
    $migTablePath = "$ScriptsLocation\Scripts\" + $migTable
    Copy-Item -Path $ScriptsLocation\Scripts\gpo_backup.migtable -Destination $migTablePath
    ((Get-Content -path $migTablePath  -Raw) -replace 'CHANGEME', $dnsRoot )| Set-Content -Path $migTablePath 
    $gPOMigrationTable = (Get-ChildItem -Path "$ScriptsLocation\Scripts\" -Filter "$migTable").fullname
    .$ScriptsLocation\Scripts\Import-GPO.ps1 -BackupPath $backupPath -GPOMigrationTable $gPOMigrationTable -Verbose
    Set-Location $location
#endregion

#region Link gpo
    $GpoLinks = @(
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Devices,OU=Tier0,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Devices,OU=Tier1,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Devices,OU=Tier2,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Tier 1 Servers"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Do Not Display Logon Information" ; OU = "OU=Workstations"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Restrict Quarantine Logon" ; OU = "OU=Quarantine"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Tier0 Restrict Server Logon" ; OU = "OU=Devices,OU=Tier0,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Tier1 Restrict Server Logon" ; OU = "OU=Devices,OU=Tier1,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Tier1 Restrict Server Logon" ; OU = "OU=Tier 1 Servers"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Tier2 Restrict Workstation Logon" ; OU = "OU=Devices,OU=Tier2,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Tier2 Restrict Workstation Logon" ; OU = "OU=Workstations"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Tier0 PAW Configuration - Computer" ; OU = "OU=Devices,OU=Tier0,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Tier0 PAW Configuration - User" ; OU = "OU=Accounts,OU=Tier0,OU=Admin"; Order = 1 ; LinkEnabled = 'No' }),
        $(New-Object PSObject -Property @{ Name = "Tier0 PAW Configuration - User PAC" ; OU = "OU=Accounts,OU=Tier0,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Tier1 PAW Configuration - Computer" ; OU = "OU=Devices,OU=Tier1,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' }),
        $(New-Object PSObject -Property @{ Name = "Tier1 PAW Configuration - User" ; OU = "OU=Accounts,OU=Tier1,OU=Admin"; Order = 1 ; LinkEnabled = 'NO' })
        $(New-Object PSObject -Property @{ Name = "Tier1 PAW Configuration - User PAC" ; OU = "OU=Accounts,OU=Tier1,OU=Admin"; Order = 1 ; LinkEnabled = 'YES' })
    )
    .$ScriptsLocation\Scripts\Link-GpoToOU.ps1 -GpoLinks $GpoLinks -Verbose
     Set-Location $location

dsa.msc
gpmc.msc
#endregion

#region Setup Computer Objects 
    Get-ADComputer -Identity vm-cl01-plc | Move-ADObject -TargetPath "OU=Quarantine,DC=Azureblog,DC=pl"
    Get-ADComputer -Identity vm-srv01-plc | Move-ADObject -TargetPath "OU=Devices,OU=Tier0,OU=Admin,DC=Azureblog,DC=pl"
    Get-ADCOmputer -Identity vm-cl01-plc
    Get-ADComputer -Identity vm-srv01-plc
#endregion

#region Tier0PAWUser on vm-srv01-plc
    whoami /groups
    net user testuser zaq12WSX /add
    [System.Net.WebProxy]::GetDefaultProxy() | select address
#endregion

#region Tier0PAWMAintenancer on vm-srv01-plc
    whoami /groups
    net user testuser zaq12WSX /add
    net user testuser
    net user testuser /del
    [System.Net.WebProxy]::GetDefaultProxy() | select address
#endregion

Set-Location $location
