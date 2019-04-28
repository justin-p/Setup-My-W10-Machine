
Function TestAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		read-host 'Not running as admin'
		Exit
	}
}
Function InstallDependencies {
	. (Join-Path $(Get-ScriptDirectory) 'src\chocolatey\install.ps1')
	choco feature enable -n allowGlobalConfirmation
	cinst boxstarter
	cinst git
	ReloadPath
}
Function ImportBoxstarter {
	Import-Module -Name 'C:\ProgramData\Boxstarter\Boxstarter.Chocolatey'
	Import-Module -Name 'C:\ProgramData\Boxstarter\Boxstarter.Common'
	Import-Module -Name 'C:\ProgramData\Boxstarter\Boxstarter.Bootstrapper'
	Import-Module -Name 'C:\ProgramData\Boxstarter\Boxstarter.WinConfig'
}
Function ReloadPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
Function RebootIfNeeded {
    if (Test-PendingReboot) {
        Invoke-Reboot 
    }
}