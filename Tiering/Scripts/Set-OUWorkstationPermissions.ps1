<#
    .Example
    $List = @(
        $(New-Object PSObject -Property @{Group = "ServiceDeskOperators"; OUPrefix = "OU=Workstations"})
    .\Set-OUWorkstationPermissions.ps1 -list $list -Verbose
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)][PSOBject] $List
)
Import-Module ActiveDirectory

$rootdse = Get-ADRootDSE
$domain = Get-ADDomain
$guidmap = @{ }
Get-ADObject -SearchBase ($rootdse.SchemaNamingContext) -LDAPFilter "(schemaidguid=*)" -Properties lDAPDisplayName, schemaIDGUID | ForEach-Object { $guidmap[$_.lDAPDisplayName] = [System.GUID]$_.schemaIDGUID }
$List | ForEach-Object {
    $ouPrefix = $_.OUPrefix
    $Group = $_.Group
    $ouPath = "$OUPrefix,$($domain.DistinguishedName)"
    $ou = Get-ADOrganizationalUnit -Identity $OUPAth
    $adGroup = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity $Group).SID
    $acl = Get-ACL -Path "AD:$($ou.DistinguishedName)"
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "CreateChild", "Allow", $guidmap["Computer"], "All"))
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ReadProperty", "Allow", "Descendents", $guidmap["Computer"]))
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "WriteProperty", "Allow", "Descendents", $guidmap["Computer"]))
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ReadProperty", "Allow", $guidmap["msTPM-OwnerInformation"], "Descendents", $guidmap["computer"]))
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ReadProperty", "Allow", $guidmap["msFVE-KeyPackage"], "Descendents", $guidmap["msFVE-RecoveryInformation"]))
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ReadProperty", "Allow", $guidmap["msFVE-RecoveryPassword"], "Descendents", $guidmap["msFVE-RecoveryInformation"]))
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ReadProperty", "Allow", $guidmap["msFVE-VolumeGuid"], "Descendents", $guidmap["msFVE-RecoveryInformation"]))
    Write-Host "Configuring Workstation Permissions on '$ouPath' for group '$Group'" -ForegroundColor Green
    Write-Verbose 'Set-ACL -ACLObject $acl -Path ("AD:\" + ($ou.DistinguishedName))'
    Set-ACL -ACLObject $acl -Path ("AD:\" + ($ou.DistinguishedName))
} 
