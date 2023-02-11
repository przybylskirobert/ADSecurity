Throw "this is not a robust file"
$location = Get-Location
Set-Location C:\Tools\LAPS
$dsnAME = (Get-ADDomain).DistinguishedName
$domain = $env:USERDNSDOMAIN

Throw "Please download LAPS from aka.ms/laps and put the msi files into the C:\Tools\LAPS\LAPS"

#Copy LAPS msi files to sysvol
    .\CopyTo-Sysvol.ps1 -FilesPath C:\ADSecurity\LAPS\LAPS -Verbose

#schema extension with LAPS     #64 on DC LAB
        $lapsPath = "\\$Domain\SysVol\$Domain\Scripts\LAPS\LAPS.x64.msi"
        $expression = "C:\Windows\System32\msiexec.exe /i $lapsPath ADDLOCAL=CSE,Management,Management.UI,Management.PS,Management.ADMX /quiet"
        Invoke-Expression $expression
<#
    #64 on PAW
        $lapsPath = "\\$Domain\SysVol\$Domain\Scripts\LAPS.x64.msi"
        $expression = "C:\Windows\System32\msiexec.exe /i $LapsPath ADDLOCAL=CSE,Management.PS /quiet"
        Invoke-Expression $expression
    #32 on PAW
        $lapsPath = "\\$Domain\SysVol\$Domain\Scripts\LAPS.x32.msi"
        $expression = "C:\Windows\System32\msiexec.exe /i $LapsPath ADDLOCAL=CSE,Management.PS /quiet"
        Invoke-Expression $expression
#>
#run as a member of schema admins group
    Import-module AdmPwd.PS  
    Update-AdmPwdADSchema 

#Allow computers  to store passwords
    Import-module AdmPwd.PS  
    Set-AdmPwdComputerSelfPermission -Identity "OU=Devices,OU=Tier0,OU=Admin,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=Tier0 Servers,OU=Tier0,OU=Admin,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=Devices,OU=Tier1,OU=Admin,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=Tier 1 Servers,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=Workstations,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=Quarantine,$dsname"

#Allow users to read passwords
    Import-module AdmPwd.PS  
    Set-AdmPwdReadPasswordPermission -Identity "OU=Devices,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=Tier0 Servers,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=Devices,OU=Tier1,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins","tier1admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=Tier 1 Servers,$dsname" -AllowedPrincipals "Domain Admins","tier1admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=Workstations,$dsname" -AllowedPrincipals "Domain Admins","tier1admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=Quarantine,$dsname" -AllowedPrincipals "Domain Admins","tier2admins"

#Alow users to reset passwords
    Import-module AdmPwd.PS  
    Set-AdmPwdResetPasswordPermission -Identity "OU=Devices,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=Tier0 Servers,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=Devices,OU=Tier1,OU=Admin,$dsname" -AllowedPrincipals "Domain Admins","tier1admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=Tier 1 Servers,$dsname" -AllowedPrincipals "Domain Admins","tier1admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=Workstations,$dsname" -AllowedPrincipals "Domain Admins","tier1admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=Quarantine,$dsname" -AllowedPrincipals "Domain Admins","tier2admins"

#LAPS Installation GPO
	Name: LAPSInstallation-v1.0
    Source Starter GPO: (none)
    GPO Status: User configuration settings disabled
    Category 	 	 	 	Package Placement	 	 	 	 	 	 	 	Deploy Software	Additional Info
    Software Installation	\\$domain\sysvol\$domain\scripts\LAPS\LAPS.x64.msi   Assigned	
    Category 	 	 	 	Package Placement	 	 	 	 	 	 	 	Deploy Software	Additional Info
    Software Installation	\\$domain\sysvol\$domainscripts\LAPS\LAPS.x86.msi    Assigned		Uncheck Make this 32-bit x86 appliction available to Win64 machines

#LAPS Configuration Policy
    Name: LAPSConfiguration-v1.0
    Source Starter GPO: (none)
    GPO Status: User configuration settings disabled
    Category					Subcategory		Policy	 								Setting

    Administrative Templates 	LAPS			Password Settings						Enabled
                                                                                        Password Complexity: Large letters + small letters + numbers + specials
