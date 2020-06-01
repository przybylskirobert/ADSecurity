[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)] [string] $DomainGroup,
    [Parameter(Mandatory=$True)] [string] $PolicyName
)

$taskName = "Update_$($PolicyName)_Users"

$argument = "-NoProfile -command " + '"' + "& Get-ADGroupMember -Recursive -Identity " + "'" + $DomainGroup + "'" + "| ForEach-Object {Set-ADAccountAuthenticationPolicySilo -AuthenticationPolicy " + $PolicyName + " -Identity " + '$_' + ".SamAccountName}" + '"'
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $argument
$trigger =  New-ScheduledTaskTrigger -Daily -At 12am 
$STPrin = New-ScheduledTaskPrincipal -GroupId "System" -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Principal $STPrin -Description "Update Authentication policy '$PolicyName' users with '$DomainGroup' members"
