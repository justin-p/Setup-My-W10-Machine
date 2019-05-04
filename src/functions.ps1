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
		$GitURLs += $(New-Object -TypeName PSObject -Property @{Path="$("$env:SystemDrive\_git\github\dotfiles")";Url="https://github.com/justin-p/dotfiles"})
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
		$("${env:ProgramFiles(x86)}\KeePass Password Safe 2\Plugins"),
		$("$env:HOME\Documents\WindowsPowerShell\PoshThemes")
	)
	ForEach ($Path in $Paths) {
		if (!(Test-Path $Path )) {
			[void](New-Item -Path $Path -ItemType Directory)
		}
	}
}
function SetupWSL {
	# Based on https://www.reddit.com/r/bashonubuntuonwindows/comments/a3ql25/surpress_enter_new_unix_username_for_an_automated/
	$WSLCredential = Get-Credential -Message "Enter Username and Password used for WSL Distros setup"
	@("$env:LOCALAPPDATA\Microsoft\WindowsApps\ubuntu1804.exe","$env:LOCALAPPDATA\Microsoft\WindowsApps\kali.exe") | ForEach-Object {
        Start-Process $_ -ArgumentList "install --root" -Wait
        Start-Process $_ -ArgumentList "run adduser $($WSLCredential.GetNetworkCredential().UserName) --gecos `"First,Last,RoomNumber,WorkPhone,HomePhone`" --disabled-password" -Wait
		Start-Process $_ -ArgumentList "run echo '$($WSLCredential.GetNetworkCredential().UserName):$($WSLCredential.GetNetworkCredential().Password)' | sudo chpasswd" -Wait
		Start-Process $_ -ArgumentList "run usermod -aG sudo $($WSLCredential.GetNetworkCredential().UserName)" -Wait
		Start-Process $_ -ArgumentList "config --default-user $($WSLCredential.GetNetworkCredential().UserName)" -Wait
	}
}
#endregion