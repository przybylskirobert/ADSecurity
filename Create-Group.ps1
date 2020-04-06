[CmdletBinding()]
param(
    [string] $CSVfile
)
$dNC = (Get-ADRootDSE).defaultNamingContext
$groups = Import-Csv $CSVfile
foreach ($group in $groups) {
    $groupName = $group.Name
    $groupOUPrefix = $group.OU
    $destOU = $group.OU + "," + $dNC
    $groupDN = "CN=" + $groupName + "," + $destOU
    $checkForGroup = Get-ADGroup -filter 'Name -eq $groupName' -ErrorAction SilentlyContinue
    If ($checkForGroup.count -eq 0 ) {
        Write-Verbose "Creating new Group '$($Group.samAccountName)' under '$destOU'"
        New-ADGroup -Name $Group.Name -SamAccountName $Group.samAccountName -GroupCategory $Group.GroupCategory -GroupScope $Group.GroupScope -DisplayName $Group.DisplayName -Path $destOU -Description $Group.Description
        If ($Group.Membership -ne "") {
            Write-Verbose "Adding Group Membership '$($Group.Membership)' for group '$($Group.samAccountName)'"
            Add-ADPrincipalGroupMembership -Identity $Group.samAccountName -MemberOf $Group.Membership
        }
        $error.Clear()
    } 
    Else {
        Write-Verbose "Group '$($Group.samAccountName)'already exists."
    }
}