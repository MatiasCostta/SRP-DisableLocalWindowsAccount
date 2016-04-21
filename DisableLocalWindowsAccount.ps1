# Copyright 2016 LogRhythm Inc.   
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.  You may obtain a copy of the License at;
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the License for the specific language governing permissions and limitations under the License.

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
