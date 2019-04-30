#region general functions
Function TestAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		read-host 'Not running as admin'
		Exit
	}
}
Function ReloadPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}
Function RebootIfNeeded {
    if (Test-PendingReboot) {
        Invoke-Reboot 
    }
}
Function ImportBoxstarter {
	@('C:\ProgramData\Boxstarter\Boxstarter.Chocolatey',
	'C:\ProgramData\Boxstarter\Boxstarter.Common',
	'C:\ProgramData\Boxstarter\Boxstarter.Bootstrapper',
	'C:\ProgramData\Boxstarter\Boxstarter.WinConfig') | ForEach-Object {
		Import-Module -Name $_
	}
}
#endregion
#region Install Functioms
Function InstallDependencies {
	. (Join-Path $(Get-ScriptDirectory) 'src\chocolatey\install.ps1')
	choco feature enable -n allowGlobalConfirmation
	cinst boxstarter
	cinst git
	ReloadPath
}
Function InstallKeePassPlugins {
	ForEach ($Plugin in $(Get-ChildItem $(Join-Path $(Get-ScriptDirectory) '.\src\KeePass Plugin\'))) {
		Copy-Item $($plugin.FullName) $("${env:ProgramFiles(x86)}\KeePass Password Safe 2\Plugins")
	}
}
Function InstallFonts {
    . $(Join-Path $(Get-ScriptDirectory) 'src\InstallFonts\install.ps1')
}
Function InstallDotfiles {
	function GitURLsObj {
		$GitURLs = @()
		$GitURLs += $(New-Object -TypeName PSObject -Property @{path="$("$env:SystemDrive\_git\github\dotfiles")";url="https://github.com/justin-p/dotfiles"})
		Return $GitURLs
	}
	Function CloneRepos {
		GitURLsObj | ForEach-Object {
			git clone $_.Url $_.Path
		}
	}	
	CloneRepos
	. $("$env:SystemDrive\_git\github\dotfiles\bootstrap.ps1")
}
#endregion

#region Setup Functions
Function SetupFolders {
	$Paths = @(
		$("$env:SystemDrive\_git\github"),
		$("${env:ProgramFiles(x86)}\KeePass Password Safe 2\Plugins")
	)
	ForEach ($Path in $Paths) {
		if (!(Test-Path $Path )) {
			[void](New-Item -Path $Path -ItemType Directory)
		}
	}
}
#endregion