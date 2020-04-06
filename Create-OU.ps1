[CmdletBinding()]
param(
    [PSObject] $OUs
)
$dNC = (Get-ADRootDSE).defaultNamingContext
$OUs | ForEach-Object {
    $name = $_.Name
    $parentOU = $_.ParentOU
    
    if ($ParentOU -eq '') {
        $ouPath = "$dNC"
        $testOUpath = "OU=$name,$dNC"
    }
    else {
        $ouPath = "$parentOU,$dNC"
        $testOUPath = "OU=$name,$parentOU,$dNC"
    }
    
    $OUTest = (Get-ADOrganizationalUnit -Filter 'DistinguishedName -like $testOUpath' | Measure-Object).Count
    if ($OUtest -eq 0) {
        Write-Verbose "Creating new OU '$testOUPath'"
        New-ADOrganizationalUnit -Name $name -Path $OUPath -ProtectedFromAccidentalDeletion:$true
    }
    else {
        Write-Verbose "OU '$name' already exists under '$ouPath'"
    }
}