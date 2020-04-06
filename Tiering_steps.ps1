throw "This is not a robus script"
$location = Get-Location
Set-Location C:\Tools

Import-Module ActiveDirectory
$dNC = (Get-ADRootDSE).defaultNamingContext


#region Create Top Level OU's
$OUs = @(
    $(New-Object PSObject -Property @{Name = "Admin"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "Groups"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "Tier 1 Servers"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "Workstations"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "User accounts"; ParentOU = "" }),
    $(New-Object PSObject -Property @{Name = "Quarantine"; ParentOU = "" })
)
.\Create-OU.ps1 -OUs $OUs -Verbose
#endRegion 

#region Create Sub Admin OU's
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
.\Create-OU.ps1 -OUs $OUs -Verbose
#endRegion

#region Create Sub Groups OU's
$OUs = @(
    $(New-Object PSObject -Property @{Name = "Security Groups"; ParentOU = "ou=Groups" }),
    $(New-Object PSObject -Property @{Name = "Distribution Groups"; ParentOU = "ou=Groups" }),
    $(New-Object PSObject -Property @{Name = "Contacts"; ParentOU = "ou=Groups" })
)
.\Create-OU.ps1 -OUs $OUs -Verbose
#endRegion

#region Create Sub Tier 1 Servers OU's
$OUs = @(
    $(New-Object PSObject -Property @{Name = "Application"; ParentOU = "ou=Tier 1 Servers" }),
    $(New-Object PSObject -Property @{Name = "Collaboration"; ParentOU = "ou=Tier 1 Servers" }),
    $(New-Object PSObject -Property @{Name = "Database"; ParentOU = "ou=Tier 1 Servers" }),
    $(New-Object PSObject -Property @{Name = "Messaging"; ParentOU = "ou=Tier 1 Servers" }),
    $(New-Object PSObject -Property @{Name = "Staging"; ParentOU = "ou=Tier 1 Servers" })
)
.\Create-OU.ps1 -OUs $OUs -Verbose
#endRegion

#region Create Sub Tier 1 Servers OU's
$OUs = @(
    $(New-Object PSObject -Property @{Name = "Desktops"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Kiosks"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Laptops"; ParentOU = "ou=Workstations" }),
    $(New-Object PSObject -Property @{Name = "Staging"; ParentOU = "ou=Workstations" })
)
.\Create-OU.ps1 -OUs $OUs -Verbose
#endRegion

#region Create Sub User Accounts OU's
$OUs = @(
    $(New-Object PSObject -Property @{Name = "Enabled Users"; ParentOU = "ou=User Accounts" }),
    $(New-Object PSObject -Property @{Name = "Disabled Users"; ParentOU = "ou=User Accounts" })
)
.\Create-OU.ps1 -OUs $OUs -Verbose
#endRegion

#Region Block inheritance for PAW OUs
Set-GpInheritance -Target "OU=Devices,OU=Tier0,OU=Admin,$dnc" -IsBlocked Yes | Out-Null
Set-GpInheritance -Target "OU=Devices,OU=Tier1,OU=Admin,$dnc" -IsBlocked Yes | Out-Null
Set-GpInheritance -Target "OU=Devices,OU=Tier2,OU=Admin,$dnc" -IsBlocked Yes | Out-Null
#endRegion

#Region create Groups 
$csv = Read-Host -Prompt "Please provide full path to Groups csv file"
.\Create-Group.ps1 -CSVfile $csv -Verbose
#endRegion

#Region Create OU Delegation
$List = @(
    $(New-Object PSObject -Property @{Group = "ServiceDeskOperators"; OUPrefix = "OU=User Accounts" })
)
.\Set-OUUserPermissions.ps1 -list $list -Verbose 

$List = @(
    $(New-Object PSObject -Property @{Group = "ServiceDeskOperators"; OUPrefix = "OU=Workstations" })
)
.\Set-OUWorkstationPermissions.ps1 -list $list -Verbose

$List = @(
    $(New-Object PSObject -Property @{Group = "WorkstationMaintenance"; OUPrefix = "OU=Quarantine" }),
    $(New-Object PSObject -Property @{Group = "WorkstationMaintenance"; OUPrefix = "OU=Workstations" }),
    $(New-Object PSObject -Property @{Group = "Tier1ServerMaintenance"; OUPrefix = "OU=Tier 1 Servers" })
)
.\Set-OUComputerPermissions.ps1 -list $list -Verbose

$List = @(
    $(New-Object PSObject -Property @{Group = "Tier0ReplicationMaintenance"; OUPrefix = "" })
)
.\Set-OUReplicationPermissions.ps1 -list $list -Verbose

$List = @(
    $(New-Object PSObject -Property @{Group = "Tier1ServerMaintenance"; OUPrefix = "OU=Tier 1 Servers" })
)
.\Set-OUGPOPermissions.ps1 -list $list -Verbose

$List = @(
    $(New-Object PSObject -Property @{Group = "Tier1ServerMaintenance"; OUPrefix = "OU=Tier 1 Servers" })
)
.\Set-OUGPOPermissions.ps1 -list $list -Verbose
#endRegion

Set-Location $location