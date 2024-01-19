<#
    .EXAMPLE
    $GpoLinks = @(
        $(New-Object PSObject -Property @{ Name = "POLICYNAME" ; OU = "OUPATH"; Order = 1; LinkEnabled = 'YES'}),
    )
    .\Link-GpoToOU.ps1 -GpoLinks $GpoLinks -Verbose
#>


[CmdletBinding()]
param(
    [Parameter(Mandatory = $True)][PSObject] $GpoLinks
)
Import-Module ActiveDirectory
$DC = (Get-ADDomain).DistinguishedName

$GpoLinks | foreach-Object {
    $name = $_.Name
    $OU = $_.ou
    $order = $_.Order
    $LinkEnabled = $_.LinkEnabled
    if ($OU -eq "") {
        
        $ouPath = $DC
    }
    else {
        $ouPath = "$OU,$DC"
    }
    Write-Verbose "Linking GPO '$name' into OU '$ouPath'"
    New-GPLink -Name $name -Target $ouPath -LinkEnabled $LinkEnabled -Order $order
}
