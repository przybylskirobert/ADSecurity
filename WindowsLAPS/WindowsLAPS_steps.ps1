Throw "this is not a robust file - and works on 2016 Domain Functional Level"

$location = Get-Location
$dsnAME = (Get-ADDomain).DistinguishedName
$netbios = (Get-ADDomain).Name
$ScriptsLocation =  "C:\Tools\ADSecurity\WindowsLAPS"
Set-Location $ScriptsLocation

#Region Update Policy Definitions
    Copy-Item C:\Windows\PolicyDefinitions -Recurse -Destination C:\Windows\Sysvol\domain\Policies\ -Force
#endREgion


#region WindowsLaps Schema
	Update-LapsADSchema -Verbose
#endregion

#region GrantPermissions
	Set-LapsADComputerSelfPermission -Identity "OU=Devices,OU=Tier0,OU=Admin,$dsname"
	Set-LapsADComputerSelfPermission -Identity "OU=Tier0 Servers,OU=Tier0,OU=Admin,$dsname"
	Set-LapsADComputerSelfPermission -Identity "OU=Devices,OU=Tier1,OU=Admin,$dsname"
	Set-LapsADComputerSelfPermission -Identity "OU=Tier 1 Servers,$dsname"
	Set-LapsADComputerSelfPermission -Identity "CN=Computers,$dsname"
	Set-LapsADComputerSelfPermission -Identity "OU=Quarantine,$dsname"
#endregion

#region Allow users to read passwords

    Set-LapsADReadPasswordPermission -Identity "OU=Devices,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins"
    Set-LapsADReadPasswordPermission -Identity "OU=Tier0 Servers,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins"
    Set-LapsADReadPasswordPermission -Identity "OU=Devices,OU=Tier1,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins","$netbios\tier1admins"
    Set-LapsADReadPasswordPermission -Identity "OU=Tier 1 Servers,$dsname" -AllowedPrincipals "Domain Admins","$netbios\tier1admins"
    Set-LapsADReadPasswordPermission -Identity "CN=Computers,$dsname" -AllowedPrincipals "Domain Admins","$netbios\tier2admins"
    Set-LapsADReadPasswordPermission -Identity "OU=Quarantine,$dsname" -AllowedPrincipals "Domain Admins","$netbios\tier2admins"
#endregion

#region Alow users to reset passwords
    Set-LapsADResetPasswordPermission -Identity "OU=Devices,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins"
    Set-LapsADResetPasswordPermission -Identity "OU=Tier0 Servers,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins"
    Set-LapsADResetPasswordPermission -Identity "OU=Devices,OU=Tier1,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins","$netbios\tier1admins"
    Set-LapsADResetPasswordPermission -Identity "OU=Tier 1 Servers,$dsname" -AllowedPrincipals "Domain Admins","$netbios\tier1admins"
    Set-LapsADResetPasswordPermission -Identity "CN=Computers,$dsname" -AllowedPrincipals "Domain Admins","$netbios\tier2admins"
    Set-LapsADResetPasswordPermission -Identity "OU=Quarantine,$dsname" -AllowedPrincipals "Domain Admins","$netbios\tier2admins"
#endregion

#region GPOImport
    $backupPath = "$ScriptsLocation\GPO"
    .$ScriptsLocation\Scripts\Import-GPO.ps1 -BackupPath $backupPath -Verbose
    cd $location
#endregion

#region LinkGPO
   $GpoLinks = @(
        $(New-Object PSObject -Property @{ Name = "WindowsLAPS_DSRM" ; OU = "OU=Domain Controllers"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "WindowsLAPS" ; OU = "OU=Devices,OU=Tier0,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "WindowsLAPS" ; OU = "OU=Tier0 Servers,OU=Tier0,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "WindowsLAPS" ; OU = "OU=Devices,OU=Tier1,OU=Admin"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "WindowsLAPS" ; OU = "OU=Tier 1 Servers"; Order = 1 ;LinkEnabled = 'YES'}),
        $(New-Object PSObject -Property @{ Name = "WindowsLAPS" ; OU = "OU=Quarantine"; Order = 1 ;LinkEnabled = 'YES'})
    )
    .$ScriptsLocation\Scripts\Link-GpoToOU.ps1 -GpoLinks $GpoLinks
     cd $location
#endregion