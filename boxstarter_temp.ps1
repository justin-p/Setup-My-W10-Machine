# Relaunch the script with administrator privileges
Function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -Verb RunAs
		Exit
	}
}
Function InstallDependencies {
    . (Join-Path $(Get-Location).Path 'src\chocolatey\install.ps1')
    cinst boxstarter 
}
Function RebootIfNeeded {
    if (Test-PendingReboot) {
        Invoke-Reboot 
    }
}
Function InstallWindowsUpdates {
    RebootIfNeeded
    Install-WindowsUpdate -getUpdatesFromMS -acceptEula
    RebootIfNeeded    
}
RequireAdmin
# Boxstarter options
$Boxstarter.RebootOk=$true
$Boxstarter.NoPassword=$true
$Boxstarter.AutoLogin=$true

InstallWindowsUpdates