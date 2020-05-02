<#
    .Example
    $List = @(
        $(New-Object PSObject -Property @{Group = "Tier1Admins"; OUPrefix = "OU=Groups,ou=Tier1,ou=Admin"})
    )
    .\Set-OUGroupPermissions.ps1 -list $list -Verbose 
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
$extendedrightsmap = @{ }
Get-ADObject -SearchBase ($rootdse.ConfigurationNamingContext) -LDAPFilter "(&(objectclass=controlAccessRight)(rightsguid=*))" -Properties displayName, rightsGuid | ForEach-Object { $extendedrightsmap[$_.displayName] = [System.GUID]$_.rightsGuid }

$List | ForEach-Object {
    $ouPrefix = $_.OUPrefix
    $Group = $_.Group
    $ouPath = "$OUPrefix,$($domain.DistinguishedName)"
    $ou = Get-ADOrganizationalUnit -Identity $OUPAth
    $adGroup = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity $Group).SID
    $acl = Get-ACL -Path "AD:$($ou.DistinguishedName)"
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "CreateChild", "Allow", $guidmap["group"], "ALL"))
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ReadProperty", "Allow", "Descendents", $guidmap["group"]))
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "WriteProperty", "Allow", "Descendents", $guidmap["group"]))
    Write-Verbose "Configuring Group Permissions on '$ouPath' for group '$Group'"
    Set-ACL -ACLObject $acl -Path ("AD:\" + ($ou.DistinguishedName))
}
