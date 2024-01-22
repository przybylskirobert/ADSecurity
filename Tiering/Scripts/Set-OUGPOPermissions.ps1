<#

    .Example
    $List = @(
        $(New-Object PSObject -Property @{Group = "Tier1ServerMaintenance"; OUPrefix = "OU=Tier 1 Servers"})
    )
    .\Set-OUGPOPermissions.ps1 -list $list -Verbose

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

if (test-Path -Path $List) {
    Write-Host "Working with CSV File '$List'" -ForegroundColor Green
    $List = Import-CSV -Path $List
}

$List | ForEach-Object {
    $ouPrefix = $_.OUPrefix
    $Group = $_.Group
    $ouPath = "$OUPrefix,$($domain.DistinguishedName)"
    $ou = Get-ADOrganizationalUnit -Identity $OUPAth
    $adGroup = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity $Group).SID
    $acl = Get-ACL -Path "AD:$($ou.DistinguishedName)"
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ReadProperty,WriteProperty", "Allow", $guidmap["gplink"], "All"))
    $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ReadProperty", "Allow", $guidmap["gpoptions"], "All"))
    Write-Host "Configuring GPO Permissions on '$ouPath' for group '$Group'" -ForegroundColor Green
    Write-Verbose 'Set-ACL -ACLObject $acl -Path ("AD:\" + ($ou.DistinguishedName))'
    Set-ACL -ACLObject $acl -Path ("AD:\" + ($ou.DistinguishedName))
}
