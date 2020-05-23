<#
    .EXAMPLE
    .\Execute-Script.ps1 -Path "C:\scripts\script.bin" -Credential (Get-credential)
#>

param (
    [Parameter(Mandatory)]
    [String]$BinFilePath ,
    [Parameter(Mandatory)]
    [System.Management.Automation.PSCredential]$Credential
)

$testPath = Test-Path -Path $BinFilePath
if ($testPath -eq $false) {
    Write-Error "Path '$BinFilePath' does not exists"
    break
}
$credentialTest = ($Credential.GetNetworkCredential().Password).Lenght
if ($credentialTest -eq $null) {
    Write-Error "Password lenght used is equeal 0"
    break
}

function Execute-EncryptedScript($BinFilePath, [SecureString]$Password) {
    trap { "Decryption failed"; break }
    $raw = Get-Content $BinFilePath
    $secure = ConvertTo-SecureString $raw -SecureKey $Password
    $helper = New-Object system.Management.Automation.PSCredential("test", $secure)
    $plain = $helper.GetNetworkCredential().Password
    Invoke-Expression $plain
}

Execute-EncryptedScript -BINFilePath $BinFilePath -Password $Credential.Password