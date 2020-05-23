<#
    .EXAMPLE
    .\Encrypt-Script.ps1 -Path "C:\scripts" -ScriptName 'script.ps1' -Credential (Get-credential)
#>

param (
    [Parameter(Mandatory)]
    [String]$Path,
    [Parameter(Mandatory)]
    [String]$ScriptName,
    [Parameter(Mandatory)]
    [System.Management.Automation.PSCredential]$Credential
)

$scriptPath = "$Path\$ScriptName"
$DestinationSctiptPath = $Path + "\" + [System.IO.Path]::GetFileNameWithoutExtension($ScriptName) + ".bin"

$testPath = Test-Path -Path $Path
if ($testPath -eq $false) {
    Write-Error "Path '$path' does not exists"
    break
}
else {
    $testFilePath = Test-Path -Path $scriptPath
    if ($testFilePath -eq $false) {
        Write-Error "Path '$scriptPath' does not exists"
        break
    }
}
$credentialTest = ($Credential.GetNetworkCredential().Password).Length
if ($credentialTest -eq $null) {
    Write-Error "Password lenght used is equeal 0"
    break
}

function Encrypt-Script ($ScriptPath, $DestinationSctiptPath, [SecureString]$Password) {
    $script = Get-Content $ScriptPath | Out-String
    $secure = ConvertTo-SecureString -String $script -AsPlainText -Force
    $export = $secure | ConvertFrom-SecureString -SecureKey $Password
    Set-Content $DestinationSctiptPath $export
    "Script '$ScriptPath' has been encrypted as '$DestinationSctiptPath'"
}
Encrypt-Script -ScriptPath $scriptPath -DestinationSctiptPath $DestinationSctiptPath -Password $Credential.Password
