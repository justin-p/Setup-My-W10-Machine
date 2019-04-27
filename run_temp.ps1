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
RequireAdmin
InstallDependencies