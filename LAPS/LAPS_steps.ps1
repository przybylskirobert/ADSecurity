Throw "this is not a robust file"
$location = Get-Location
$dsnAME = (Get-ADDomain).DistinguishedName
$domain = $env:USERDNSDOMAIN
$ScriptsLocation =  "C:\Tools\ADSecurity\LAPS"
Set-Location $ScriptsLocation

#Copy LAPS msi files to sysvol
    Get-ChildItem -Path "$ScriptsLocation\LAPS\Binaries\Laps" |Unblock-File
    .$ScriptsLocation\LAPS\Scripts\CopyTo-Sysvol.ps1 -FilesPath "$ScriptsLocation\LAPS\Binaries\LAPS" -DefaultSysvolPlacement -Verbose

#schema extension with LAPS     #64 on DC LAB
    $lapsPath = "\\$Domain\SysVol\$Domain\Scripts\Laps\LAPS.x64.msi"
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
    start-sleep 60
    Import-module AdmPwd.PS  
    Update-AdmPwdADSchema 
    Import-module AdmPwd.PS  

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

#Gpo Import
    $backupPath = "$ScriptsLocation\LAPS\GPO"
    .$ScriptsLocation\LAPS\Scripts\Import-GPO.ps1 -BackupPath $backupPath -Verbose
    cd $location
