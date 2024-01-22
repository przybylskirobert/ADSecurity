<#
    .Example
    $List = @(
        $(New-Object PSObject -Property @{Group = "Tier0ReplicationMaintenance"; OUPrefix = "" })
    )
    .\Set-OUReplicationPermissions.ps1 -list $list -Verbose
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

$location = Get-Location
Set-Location AD:
$configCN = $rootdse.ConfigurationNamingContext
$schemaNC = $rootdse.SchemaNamingContext
$forestDnsZonesDN = "DC=ForestDnsZones," + $rootdse.RootDomainNamingContext
$sitesDN = "CN=Sites," + $configCN
$config = @($configCN, $schemaNC, $forestDnsZonesDN, $sitesDN)

if ($List -like "*csv*") {
    if (Test-Path -Path $List){
        Write-Host "Working with CSV File '$List'" -ForegroundColor Green
        $List = Import-CSV -Path $List
    }
}

$List | ForEach-Object {
    $group = $_.Group
    $adGroup = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity $group).SID
    foreach ($configEntry in $config) {
        $acl = Get-ACL -Path($configEntry)
        $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ExtendedRight", "Allow", $extendedrightsmap["Manage Replication Topology"], "Descendents"))
        $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ExtendedRight", "Allow", $extendedrightsmap["Replicating Directory Changes"], "Descendents"))
        $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ExtendedRight", "Allow", $extendedrightsmap["Replicating Directory Changes All"], "Descendents"))
        $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ExtendedRight", "Allow", $extendedrightsmap["Replication Synchronization"], "Descendents"))
        if ($configEntry -like "CN=Configuration*" -or $configEntry -like "CN=Schema*") {
            $acl.AddAccessRule((New-Object System.DirectoryServices.ActiveDirectoryAccessRule $adGroup, "ExtendedRight", "Allow", $extendedrightsmap["Monitor active directory Replication"], "Descendents"))
        }
        Write-Host "Configuring Replication Maintenance Role Delegation on '$configEntry' for group '$group'" -ForegroundColor Green
        Write-Verbose 'Set-ACL -ACLObject $acl -Path ("AD:\" + ($domain.DistinguishedName))'
        Set-ACL -ACLObject $acl -Path ("AD:\" + ($domain.DistinguishedName))
    }
}
Set-Location $Location
