Throw "This is not a robust file"
$domain = $env:USERDNSDOMAIN
$dNC = (Get-ADRootDSE).defaultNamingContext


#region redir
$usrDN = '"' + "OU=Enabled Users,OU=User Accounts," + $dNc + '"'
redirusr $usrDN
$cmpDN = '"' + "OU=Quarantine," + $dNc + '"'
redircmp 
#endregion

#region Sites
Import-Module ActiveDirectory
Get-ADObject -SearchBase (Get-ADRootDSE).ConfigurationNamingContext `
-filter "objectclass -eq 'site'" | `
where-object { $_.Name -eq 'Default-First-Site-Name' } | `
Rename-ADObject -NewName "HQ"
$subnet = Read-Host "Please provide subnet details"
New-ADReplicationSubnet -Name $subnet -Site "HQ"
#endrgion

#region KDS Root Key
add-kdsrootkey
#add-kdsrootkey �effectivetime ((get-date).addhours(-10))
#endregion

#password policies
$TemplatePSO = New-Object Microsoft.ActiveDirectory.Management.ADFineGrainedPasswordPolicy
$TemplatePSO.PasswordHistoryCount = 24
$TemplatePSO.MinPasswordAge = [TimeSpan]::Parse("0.01:00:00")
$TemplatePSO.ComplexityEnabled = $true
$TemplatePSO.ReversibleEncryptionEnabled = $false
$TemplatePSO.LockoutDuration = "-10675199.02:48:05.4775808" 
$TemplatePSO.LockoutObservationWindow = [TimeSpan]::Parse("0.01:00:00")
$TemplatePSO.LockoutThreshold = 4
$name = "AdminsPSO"
New-ADFineGrainedPasswordPolicy -Instance $TemplatePSO -Name $name -Precedence 50 -Description "The Tiered users Password Policy" -DisplayName "Tiered Users PSO" -MaxPasswordAge "180.00:00:00" -MinPasswordLength 10
Add-ADFineGrainedPasswordPolicySubject -Identity $name -Subjects `
"Domain Admins", Tier1ServerMaintenance, tier1admins, Tier1PAWUsers, Tier2ServiceDeskOperators, tier2admins, Tier2WorkstationMaintenance
#endregion

#AD Resycle
Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target $domain -Confirm:$false
#endregion

#region DNS registration
$networkConfig = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'"
$networkConfig.SetDnsDomain("$domain")
$networkConfig.SetDynamicDNSRegistration($true, $true)
ipconfig /registerdns 
#endregion

#gmsa for MDI
$name = 'svc_MDIReadOnly'
$dcList = Get-ADGroupMember -Identity 'Domain Controllers'
New-ADServiceAccount -Name $name -DNSHostName "$($name).$domain" -PrincipalsAllowedToRetrieveManagedPassword $dcList
Test-ADServiceAccount -Identity $name
Get-ADServiceAccount -Identity $name -Properties MemberOf

#endregion
