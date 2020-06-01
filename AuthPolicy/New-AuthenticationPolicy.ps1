[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)] [string] $GroupName,
    [Parameter(Mandatory=$True)] [string] $PolicyName,
    [Parameter(Mandatory=$True)] [string] $Description,
    [Parameter(Mandatory=$True)] [string] $UserTGTLifetimeMins
)

Write-Verbose "Creating new AuthenticationPolicy '$PolicyName' with UserTGTLifetimeMins '$UserTGTLifetimeMins'"
New-ADAuthenticationPolicy -Name $PolicyName -Description $Description  -UserTGTLifetimeMins $UserTGTLifetimeMins -ProtectedFromAccidentalDeletion $true -Enforce

$sids = @()
Get-ADGroupMember -Identity $GroupName | ForEach-Object {
    $sid = $_.SID.value
    $sids += "SID($sid)"
}
if (($sids | Measure-Object).count -gt 1){$sidsj = $sids -join ", "}else{$sidsj = $sids}

Write-Verbose "Adding members from group '$GroupName' to User Sign On section under Authentication Policy '$PolicyName'"
Set-ADAuthenticationPolicy -Identity $PolicyName -UserAllowedToAuthenticateFrom "O:SYG:SYD:(XA;OICI;CR;;;WD;(Member_of_any {$sidsj}))" 
