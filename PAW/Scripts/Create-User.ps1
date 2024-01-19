<#
    .Example
    $csv = Read-Host -Prompt "Please provide full path to Groups csv file"
    .\Create-User.ps1 -CSVfile $csv -Password zaq12WSXcde3 -Verbose

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)][string] $CSVfile,
    [Parameter(Mandatory=$True)][string] $Password
)
$DNSRoot = (Get-ADDomain).DNSRoot
$DSN = (Get-ADDomain).DistinguishedName
$users = Import-Csv $CSVfile
foreach ($user in $users) {
    $name = $user.name
    $samAccountName = $user.samAccountName
    $UserPrincipalName = $samAccountName + '@' + $DNSRoot
    $parentOU = $user.ParentOU + ',' + $DSN
    $groupMembership = $user.GroupMembership
    $enabled = [bool]$user.enabled
    $checkForUser = [bool]( Get-ADUSer -Filter {SamAccountname -eq $samaccountname})
    If ($checkForUser -eq $false) {
        Write-Verbose "Creating new user '$samAccountName' under '$parentOU'"
        New-ADUser -Name $name -Path $ParentOU -SamAccountName $samAccountName -UserPrincipalName $UserPrincipalName -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -ChangePasswordAtLogon $false -Enabled $enabled -EmailAddress $UserPrincipalName
        start-sleep -Seconds 5
        if ($groupMembership -ne "") {
            $groupMembership = ($user.GroupMembership) -split ','
            foreach ($group in $groupMembership){
                Write-Verbose "Adding User '$samAccountName' to Group '$group'"
                Add-ADGroupMember -Identity $group -Members $samAccountName
            }
        }
        $error.Clear()
    } 
    Else {
        Write-Verbose "User '$samAccountName' already exists."
    }
}
