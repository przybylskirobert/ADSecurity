Throw "this is not a robust file"
$location = Get-Location
Set-Location C:\Tools\LAPS
$dsnAME = (Get-ADDomain).DistinguishedName
$domain = $env:USERDNSDOMAIN
Throw "Please download LAPS from aka.ms/laps and put the msi files into the C:\Tools\LAPS\LAPS"
#Copy LAPS msi files to sysvol
    .\CopyTo-Sysvol.ps1 -FilesPath C:\tools\LAPS\LAPS -CustomSysvolPlacement -Verbose

#schema extension with LAPS     #64 on DC LAB
        $lapsPath = "\\$Domain\SysVol\$Domain\Scripts\LAPs\LAPS.x64.msi"
        $expression = "C:\Windows\System32\msiexec.exe /i $LapsPath ADDLOCAL=CSE,Management,Management.UI,Management.PS,Management.ADMX /quiet"
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
    Set-AdmPwdComputerSelfPermission -Identity "OU=PAW,OU=Tier0,OU=Admin,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=Servers,OU=Tier0,OU=Admin,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=PAW,OU=Tier1,OU=Admin,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=Servers,OU=Tier1,OU=Admin,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=Computers,OU=AzureBlog,$dsname"
    Set-AdmPwdComputerSelfPermission -Identity "OU=Quarantine,$dsname"

#Allow users to read passwords
    Import-module AdmPwd.PS  
    Set-AdmPwdReadPasswordPermission -Identity "OU=PAW,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "t0-admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=Servers,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "t0-admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=PAW,OU=Tier1,OU=Admin,$dsname" -AllowedPrincipals "t0-admins","t1-admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=Servers,OU=Tier1,OU=Admin,$dsname" -AllowedPrincipals "t0-admins","t1-admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=Computers,OU=AzureBlog,$dsname" -AllowedPrincipals "t0-admins","t1-admins"
    Set-AdmPwdReadPasswordPermission -Identity "OU=Quarantine,$dsname" -AllowedPrincipals "t0-admins","t2-admins"

#Alow users to reset passwords
    Import-module AdmPwd.PS  
    Set-AdmPwdResetPasswordPermission -Identity "OU=PAW,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "t0-admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=Servers,OU=Tier0,OU=Admin,$dsname" -AllowedPrincipals "t0-admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=PAW,OU=Tier1,OU=Admin,$dsname" -AllowedPrincipals "t0-admins","t1-admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=Servers,OU=Tier1,OU=Admin,$dsname" -AllowedPrincipals "t0-admins","t1-admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=Computers,OU=AzureBlog,$dsname" -AllowedPrincipals "t0-admins","t1-admins"
    Set-AdmPwdResetPasswordPermission -Identity "OU=Quarantine,$dsname" -AllowedPrincipals "t0-admins","t2-admins"

#LAPS Installation GPO
	Name: LAPSInstallation-v1.0
    Source Starter GPO: (none)
    GPO Status: User configuration settings disabled
    Category 	 	 	 	Package Placement	 	 	 	 	 	 	 	Deploy Software	Additional Info
    Software Installation	\\$domain\sysvol\$domain\scripts\LAPS.x64.msi   Assigned	
    Category 	 	 	 	Package Placement	 	 	 	 	 	 	 	Deploy Software	Additional Info
    Software Installation	\\$domain\sysvol\$domainscripts\LAPS.x86.msi    Assigned		Uncheck Make this 32-bit x86 appliction available to Win64 machines

#LAPS Configuration Policy
    Name: LAPSConfiguration-v1.0
    Source Starter GPO: (none)
    GPO Status: User configuration settings disabled
    Category					Subcategory		Policy	 								Setting

    Administrative Templates 	LAPS			Password Settings						Enabled
                                                                                        Password Complexity: Large letters + small letters + numbers + specials
                                                                                        Password Length: 14
                                                                                        Password Age (Days): 30
    Administrative Templates 	LAPS			Enable local admin password management	Enabled
