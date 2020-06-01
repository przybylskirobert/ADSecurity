Throw "this is not a robust file" 
$location = Get-Location
$oldVerbosePreference = $VerbosePreference
$VerbosePreference = 'Continue'
Set-Location C:\Tools\AuthPolicy

#Region ProtectedUsers
$providedgroup = Read-Host "Please provide group that members should be added to other group."
$groupToUpdate = Read-Host "Please provide group that should be updated with new members from '$providedgroup'"
$groupMembers = Get-ADGroupMember -Identity  $providedgroup
foreach ($member in $groupMembers){
    Write-Verbose "Updating group '$groupToUpdate' with '$member'"
    Add-ADGroupMember -Identity $groupToUpdate -Members $member
}
#endregion

#region Create Tier 1 Servers Group
$csv = Read-Host -Prompt "Please provide full path to Groups csv file"
.\Create-Group.ps1 -CSVfile $csv -Verbose
$srv = Get-ADComputer -Identity srv01
$group = Get-ADGroup -Identity 'Tier1Servers'
Write-Verbose "Adding computer '$($srv.name)' to group '$($group.name)'"
Add-ADGroupMember -Identity $group -Members $srv
#endregion

#Region AuthPolicy
.\New-AuthenticationPolicy -GroupName "Tier1Servers" -PolicyName "Tier1Servers" -Description "Assigned principals can authenticate to tier-0 PAWs only" -UserTGTLifetimeMins 121
#endregion

#Region ScheduledTask
.\Register-NewScheduledTask.ps1 -DomainGroup "Tier1PAWMaint" -PolicyName "Tier1Servers"
Get-ScheduledTask -TaskName "Update_Tier1Servers_Users" | Start-ScheduledTask 
#endregion

#region EventLog
$Logs = @(
    'Microsoft-Windows-Authentication/AuthenticationPolicyFailures-DomainController',
    'Microsoft-Windows-Authentication/ProtectedUser-Client',
    'Microsoft-Windows-Authentication/ProtectedUserFailures-DomainController',
    'Microsoft-Windows-Authentication/ProtectedUserSuccesses-DomainController'
)
foreach ($logname in $logs){
    Write-Verbose "Enabling logs for '$logname'"
    $log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
    $log.IsEnabled=$true
    $log.SaveChanges()
}
#endregion

#region switch Auth Policy to Audit
Get-ADAuthenticationPolicy -Identity "Tier1Servers" | Set-ADAuthenticationPolicy -Enforce $false
#endregion

#region switch Auth Policy to Enforce
Get-ADAuthenticationPolicy -Identity "Tier1Servers" | Set-ADAuthenticationPolicy -Enforce $true
#endregion

$VerbosePreference = $oldVerbosePreference
Set-Location $location
