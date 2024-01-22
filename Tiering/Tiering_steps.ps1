throw "This is not a robus script"
$location = Get-Location
$dNC = (Get-ADRootDSE).defaultNamingContext
$ScriptsLocation =  "C:\Tools\ADSecurity\Tiering"
Set-Location $ScriptsLocation

Import-Module ActiveDirectory



#region Create OU's v1
$OUs = @(
    $(New-Object PSObject -Property @{Name = "Admin"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "Groups"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "Tier 1 Servers"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "Workstations"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "User accounts"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "Quarantine"; ParentOU = "" })
)
.$ScriptsLocation\Scripts\Create-OU.ps1 -OUs $OUs

$OUs = @(
    $(New-Object PSObject -Property @{Name = "Tier0"; ParentOU = "ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Tier1"; ParentOU = "ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Tier2"; ParentOU = "ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Accounts"; ParentOU = "ou=Tier0,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Groups"; ParentOU = "ou=Tier0,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Service Accounts"; ParentOU = "ou=Tier0,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Devices"; ParentOU = "ou=Tier0,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Tier0 Servers"; ParentOU = "ou=Tier0,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Accounts"; ParentOU = "ou=Tier1,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Groups"; ParentOU = "ou=Tier1,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Service Accounts"; ParentOU = "ou=Tier1,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Devices"; ParentOU = "ou=Tier1,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Accounts"; ParentOU = "ou=Tier2,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Groups"; ParentOU = "ou=Tier2,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Service Accounts"; ParentOU = "ou=Tier2,ou=Admin" }),
    $(New-Object PSObject -Property @{Name = "Devices"; ParentOU = "ou=Tier2,ou=Admin" })
)
.$ScriptsLocation\Scripts\Create-OU.ps1 -OUs $OUs

$OUs = @(
    $(New-Object PSObject -Property @{Name = "Security Groups"; ParentOU = "ou=Groups" }),
    $(New-Object PSObject -Property @{Name = "Distribution Groups"; ParentOU = "ou=Groups" }),
    $(New-Object PSObject -Property @{Name = "Contacts"; ParentOU = "ou=Groups" })
)
.$ScriptsLocation\Scripts\Create-OU.ps1 -OUs $OUs

$OUs = @(
    $(New-Object PSObject -Property @{Name = "Application"; ParentOU = "ou=Tier 1 Servers" }),
    $(New-Object PSObject -Property @{Name = "Collaboration"; ParentOU = "ou=Tier 1 Servers" }),
    $(New-Object PSObject -Property @{Name = "Database"; ParentOU = "ou=Tier 1 Servers" }),
    $(New-Object PSObject -Property @{Name = "Messaging"; ParentOU = "ou=Tier 1 Servers" }),
    $(New-Object PSObject -Property @{Name = "Staging"; ParentOU = "ou=Tier 1 Servers" })
)
.$ScriptsLocation\Scripts\Create-OU.ps1 -OUs $OUs

$OUs = @(
    $(New-Object PSObject -Property @{Name = "Desktops"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Kiosks"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Laptops"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Staging"; ParentOU = "ou=Workstations" })
)
.$ScriptsLocation\Scripts\Create-OU.ps1 -OUs $OUs

$OUs = @(
    $(New-Object PSObject -Property @{Name = "Enabled Users"; ParentOU = "ou=User Accounts" }),
    $(New-Object PSObject -Property @{Name = "Disabled Users"; ParentOU = "ou=User Accounts" })
)
.$ScriptsLocation\Scripts\Create-OU.ps1 -OUs $OUs
#endRegion

#region create Tiering OUs v2 
$domainOUSCsv = "$ScriptsLocation\DomainOUs.csv"
.$ScriptsLocation\Scripts\Create-OU.ps1 -OUs $domainOUSCsv    
#endregion

#Region Block inheritance for PAW OUs
Set-GpInheritance -Target "OU=Devices,OU=Tier0,OU=Admin,$dnc" -IsBlocked Yes | Out-Null
Set-GpInheritance -Target "OU=Devices,OU=Tier1,OU=Admin,$dnc" -IsBlocked Yes | Out-Null
Set-GpInheritance -Target "OU=Devices,OU=Tier2,OU=Admin,$dnc" -IsBlocked Yes | Out-Null
#endRegion

#Region create Groups 
$csv = "$ScriptsLocation\AdminGroups.csv"
.$ScriptsLocation\Scripts\Create-Group.ps1 -CSVfile $csv
$csv = "$ScriptsLocation\StandardGroups.csv"
.$ScriptsLocation\Scripts\Create-Group.ps1 -CSVfile $csv
#endRegion

#Region Create OU Delegation
$List = @(
    $(New-Object PSObject -Property @{Group = "Tier2ServiceDeskOperators"; OUPrefix = "OU=User Accounts" }),
    $(New-Object PSObject -Property @{Group = "Tier1Admins"; OUPrefix = "OU=Accounts,ou=Tier1,ou=Admin" }),
    $(New-Object PSObject -Property @{Group = "Tier1Admins"; OUPrefix = "OU=Service Accounts,ou=Tier1,ou=Admin" }),
    $(New-Object PSObject -Property @{Group = "Tier2Admins"; OUPrefix = "OU=Accounts,ou=Tier2,ou=Admin" }),
    $(New-Object PSObject -Property @{Group = "Tier2Admins"; OUPrefix = "OU=Service Accounts,ou=Tier2,ou=Admin" })
)
.$ScriptsLocation\Scripts\Set-OUUserPermissions.ps1 -list $list 

$List = @(
    $(New-Object PSObject -Property @{Group = "Tier2ServiceDeskOperators"; OUPrefix = "OU=Workstations" }),
    $(New-Object PSObject -Property @{Group = "Tier1Admins"; OUPrefix = "OU=Devices,ou=Tier1,ou=Admin" }),
    $(New-Object PSObject -Property @{Group = "Tier2Admins"; OUPrefix = "OU=Devices,ou=Tier2,ou=Admin" })
)
.$ScriptsLocation\Scripts\Set-OUWorkstationPermissions.ps1 -list $list

$List = @(
    $(New-Object PSObject -Property @{Group = "Tier1Admins"; OUPrefix = "OU=Groups,ou=Tier1,ou=Admin"}),
    $(New-Object PSObject -Property @{Group = "Tier2Admins"; OUPrefix = "OU=Groups,ou=Tier2,ou=Admin"})
)
.$ScriptsLocation\Scripts\Set-OUGroupPermissions.ps1 -list $list

$List = @(
    $(New-Object PSObject -Property @{Group = "Tier2WorkstationMaintenance"; OUPrefix = "OU=Quarantine" }),
    $(New-Object PSObject -Property @{Group = "Tier2WorkstationMaintenance"; OUPrefix = "OU=Workstations" }),
    $(New-Object PSObject -Property @{Group = "Tier1ServerMaintenance"; OUPrefix = "OU=Tier 1 Servers" })
)
.$ScriptsLocation\Scripts\Set-OUComputerPermissions.ps1 -list $list

$List = @(
    $(New-Object PSObject -Property @{Group = "Tier0ReplicationMaintenance"; OUPrefix = "" })
)
.$ScriptsLocation\Scripts\Set-OUReplicationPermissions.ps1 -list $list

$List = @(
    $(New-Object PSObject -Property @{Group = "Tier1ServerMaintenance"; OUPrefix = "OU=Tier 1 Servers" })
)
.$ScriptsLocation\Scripts\Set-OUGPOPermissions.ps1 -list $list

#endRegion

Set-Location $location
