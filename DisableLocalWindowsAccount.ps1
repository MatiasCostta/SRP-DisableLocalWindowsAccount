# Set up a trap to properly exit on terminating exceptions
trap [Exception] {
	write-error $("TRAPPED: " + $_)
	exit 1
	}

$TargetHost = $args[0]
$TargetAccount = $args[1]
$UserName = $args[2]
$password = $args[3]


$localHost = [System.Net.Dns]::GetHostName()
$localIP = [System.Net.Dns]::GetHostAddresses("$localHost")

if(-not $?)	{
		Write-Error "Unable to determine if target host is local or remote"
		exit 1
		}

if($localHost -like $TargetHost -OR $localIP -like $TargetHost) {
$user = Get-WMIObject -Class Win32_UserAccount -computername "$TargetHost" -filter "Name = '$TargetAccount'"
$user.Disabled = 1
$user.Put()
				}

else {
$securePassword = new-Object System.Security.SecureString
$password.ToCharArray() | % { $securePassword.AppendChar($_) }
$credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist "$TargetHost\$UserName",$securePassword
$user = Get-WMIObject -Class Win32_UserAccount -computername "$TargetHost" -filter "Name = '$TargetAccount'"  -Credential $credential
$user.Disabled = 1
$user.Put()
}
if(-not $?)	{
		Write-Error "Unable to get WMI Object...check permissions"
		exit 1
		}
Write-Host "Local account $TargetAccount disabled on $TargetHost"