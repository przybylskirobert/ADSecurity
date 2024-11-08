 param (
    [string] $PolicyName,
    [string] $ComputersGroupName,
    [string] $UsersGroupName,
    [string[]] $OUsToInclude,
     [int] $UserTGTLifetimeMins = 121,
    [string] $Description = "Assigned principals can authenticate to specific resources"

)

$dsnAME = (Get-ADDomain).distinguishedname

$siloDN = $null
$siloname = $null
$authPolicyDN = $null
$authNPolicySiloMembers = $null
$userAllowedToAuthenticateFrom  = $null

$policyExists = $false
try {
    Get-ADAuthenticationPolicy -Identity $PolicyName | Out-Null
}
catch {
    $policyExists = $true
}

if ($policyExists -ne $false){
    Write-Host "Creating new AuthenticationPolicy '$PolicyName' with UserTGTLifetimeMins '$UserTGTLifetimeMins'" -ForegroundColor Green
    Write-Verbose 'New-ADAuthenticationPolicy -Name $PolicyName -Description $Description  -UserTGTLifetimeMins $UserTGTLifetimeMins -ProtectedFromAccidentalDeletion $true -Enforce'
    New-ADAuthenticationPolicy -Name $PolicyName -Description $Description  -UserTGTLifetimeMins $UserTGTLifetimeMins -ProtectedFromAccidentalDeletion $true -Enforce
}
else {
    Write-Host "Authentication Policy '$PolicyName' already exists" -ForegroundColor Yellow
}

$siloName = $PolicyName + "_Silo"
$authPolicyDN = (Get-ADAuthenticationPolicy $PolicyName).DistinguishedName
$authNPolicySiloMembers = @()
$authNPolicySiloMembers += (Get-ADGroupMember -Identity $UsersGroupName).distinguishedName
$authNPolicySiloMembers += (Get-ADGroupMember -Identity $ComputersGroupName).distinguishedName

$siloExists = $false
try {
Get-ADAuthenticationPolicySilo -Identity $siloName | Out-Null
}
catch {
    $siloExists = $true
}

$siloDN = (Get-ADAuthenticationPolicySilo $siloName).DistinguishedName
if ($siloExists -ne $false){
    Write-Host "Creating new AuthenticationPolicySilo '$siloName'" -ForegroundColor Green
    Write-Verbose 'New-ADAuthenticationPolicySilo -Name $siloName  -OtherAttributes:@{"msDS-ComputerAuthNPolicy"= $authPolicyDN;"msDS-ServiceAuthNPolicy" = $authPolicyDN; ;"msDS-UserAuthNPolicy" = $authPolicyDN}  -ProtectedFromAccidentalDeletion $true'
    Write-Verbose 'Set-ADObject -Add:@{"msDS-AuthNPolicySiloMembers"= $authNPolicySiloMembers } -Identity $authPolicyDN'
    New-ADAuthenticationPolicySilo -Name $siloName  -OtherAttributes:@{"msDS-ComputerAuthNPolicy"= $authPolicyDN;"msDS-ServiceAuthNPolicy" = $authPolicyDN; ;"msDS-UserAuthNPolicy" = $authPolicyDN}  -ProtectedFromAccidentalDeletion $true 
    Set-ADObject  -Identity $siloDN -Add:@{'msDS-AuthNPolicySiloMembers'= $authNPolicySiloMembers }
}
else {
    Write-Host "Authentication Policy Silo '$siloName' already exists"  -ForegroundColor Yellow
}

foreach ($entry in $authNPolicySiloMembers){ 
    Write-Host "Updating AD Account '$entry' with AuthenticationPolicySiloPolicy '$siloDN'"  -ForegroundColor Green
    Write-Verbose 'Set-ADAccountAuthenticationPolicySilo -AuthenticationPolicySilo $siloDN -Identity $entry'
    Set-ADAccountAuthenticationPolicySilo -AuthenticationPolicySilo $siloDN -Identity $entry
}


$userAllowedToAuthenticateFrom = 'O:SYG:SYD:(XA;OICI;CR;;;WD;(@USER.ad://ext/AuthenticationSilo == ' + '"' + $siloName + '"' + "))"
Set-ADAuthenticationPolicy -Identity $PolicyName -UserAllowedToAuthenticateFrom $userAllowedToAuthenticateFrom -UserTGTLifetimeMins $UserTGTLifetimeMins
Get-ADAuthenticationPolicy -Identity $PolicyName | Set-ADAuthenticationPolicy -Enforce $false
Get-ADAuthenticationPolicySilo -Identity $siloName| Set-ADAuthenticationPolicySilo -Enforce $false

$authNPolicySiloMembers = '"' + ($authNPolicySiloMembers -join ', ') + '"'
$taskName = "Update_AuthPolicy_$($PolicyName)_objects"
#$argument = "-NoProfile -command " + '" & $authNPolicySiloMembers = @() ;$authNPolicySiloMembers += (Get-ADGroupMember -Identity ' + "'" + $UsersGroupName + "'" + ').distinguishedName ; $authNPolicySiloMembers += (Get-ADGroupMember -Identity ' + "'" +  $ComputersGroupName + "'" + ').distinguishedName ; foreach ($entry in $authNPolicySiloMembers){ Set-ADObject  -Identity ' + "'" + $siloDN + "'" +" -Add:@{'msDS-AuthNPolicySiloMembers'= " + '$entry} ; Set-ADAccountAuthenticationPolicySilo -AuthenticationPolicySilo ' + "'" + $siloDN + "'" + '-Identity $entry }'
$argument = "-NoProfile -command " + '" & $authNPolicySiloMembers = @() ; $authNPolicySiloMembers += (Get-ADGroupMember -Identity ' + "'" + $UsersGroupName + "'" + ').distinguishedName ;  $authNPolicySiloMembers += (Get-ADGroupMember -Identity ' + "'" +  $ComputersGroupName + "'" + ').distinguishedName ;' + 'Set-ADObject  -Identity ' + "'" + $siloDN + "'" + ' -Add:@{' + "'" + 'msDS-AuthNPolicySiloMembers' + "'" + ' = ' + '$authNPolicySiloMembers' + ' } ;' + 'foreach ($entry in $authNPolicySiloMembers){ Set-ADObject  -Identity ' + "'" + $siloDN + "'" +" -Add:@{'msDS-AuthNPolicySiloMembers'= " + '$entry} ; Set-ADAccountAuthenticationPolicySilo -AuthenticationPolicySilo ' + "'" + $siloDN + "'" + '-Identity $entry ; }' + '"'
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $argument
$trigger =  New-ScheduledTaskTrigger -Daily -At 12am 
$STPrin = New-ScheduledTaskPrincipal -GroupId "System" -RunLevel Highest
Write-Host "Creating Scheduled task '$taskName' to update authentication policy '$PolicyName' with users from the group '$UsersGroupName'" -ForegroundColor Green
Write-Verbose 'Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Principal $STPrin -Description "Update Authentication policy $PolicyName users with $UsersGroupName members"'
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Principal $STPrin -Description "Update Authentication policy '$PolicyName' users with '$UsersGroupName' members"
Get-ScheduledTask -TaskName $taskName | Start-ScheduledTask 
