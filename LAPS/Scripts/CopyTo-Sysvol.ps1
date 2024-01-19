<#
    .SYNOPSIS 
    Run get-help -example CopyTo-Sysvol.ps1 for examples

    .EXAMPLE
        .\CopyTo-Sysvol.ps1 -FilesPath C:\LAPS -DefaultSysvolPlacement -Verbose
        VERBOSE: Declared SYSVOL path: 'C:\Windows\Sysvol\'
        VERBOSE: Folder :'C:\Windows\Sysvol\\Sysvol\azureblog.pl\scripts' already exists
        VERBOSE: Copying files from path 'C:\LAPS' to 'C:\Windows\Sysvol\Sysvol\azureblog.pl\scripts' using Recurse mode


        Directory: C:\Windows\Sysvol\Sysvol\azureblog.pl\scripts


        Mode                LastWriteTime         Length Name                                                                                                                                
        ----                -------------         ------ ----                                                                                                                                
        d-----       02.02.2020     13:02                LAPS   
    
    .EXAMPLE
        .\CopyTo-Sysvol.ps1 -filesPath C:\LAPS -CustomSysvolPlacement -CustomSysvolPath C:\test -Verbose
        VERBOSE: Declared SYSVOL path: 'C:\test'
        VERBOSE: Folder :'C:\test\Sysvol\azureblog.pl\scripts' already exists
        VERBOSE: Copying files from path 'C:\LAPS' to 'C:\test\Sysvol\azureblog.pl\scripts' using Recurse mode


            Directory: C:\LAPS


        Mode                LastWriteTime         Length Name                                                                                                                                                                                                                              
        ----                -------------         ------ ----                                                                                                                                                                                                                              
        -a----       05.12.2019     19:56        1019904 LAPS.x64.msi                                                                                                                                                                                                                      
        -a----       05.12.2019     19:56         991232 LAPS.x86.msi                                                                                                                                                                                                                      

#>
[CmdletBinding(DefaultParametersetName = "DefaultSysvolPath")]
param (
    [parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path $_ })]
    [string]$FilesPath,
    [parameter(ParameterSetName = "DefaultSysvolPath")]
    [switch]$DefaultSysvolPlacement,    
    [parameter(ParameterSetName = "CustomSysvolPath")]
    [switch]$CustomSysvolPlacement,
    [parameter(ParameterSetName = "CustomSysvolPath", Mandatory = $true)]
    [ValidateScript( { Test-Path $_ })]
    [string]$CustomSysvolPath
)

$domain = $env:USERDNSDOMAIN
switch ($PsCmdlet.ParameterSetName) {
    "DefaultSysvolPath" {
        $sysvolPath = "C:\Windows\Sysvol"
    }
    "CustomSysvolPath" {
        $sysvolPath = $CustomSysvolPath
    }
}
Write-Host "Declared SYSVOL path: '$sysvolPath'" -ForegroundColor Green

$scriptsPath = "$sysvolPath\Sysvol\$domain\scripts"
$scriptsTest = Test-Path -Path $scriptsPath
if ($scriptstest -eq $false) {
    Write-Error "There is no such a folder: '$scriptsPath'"
}
$filesPathTest = Test-Path -Path $scriptsPath
if ($filesPathTest -eq $true) {
    Write-Host "Folder :'$scriptsPath' already exists" -ForegroundColor Yellow
}

Write-Host "Copying files from path '$FilesPath' to '$scriptsPath' using Recurse mode" -ForegroundColor Green
Write-Verbose 'Copy-Item -Path $FilesPath -Destination $scriptsPath -Recurse -Force'
Copy-Item -Path $FilesPath -Destination $scriptsPath -Recurse -Force 

Get-ChildItem -Path $scriptsPath
