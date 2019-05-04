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
function SetupW10 {
	TestAdmin
	InstallDependencies
	SetupFolders	
	InstallKeePassPlugins
	InstallFonts
	InstallDotfiles
	ImportBoxstarter
	New-PackageFromScript src\boxstarter\Boxstarter_WSLSetup.ps1        WSLSetup
	New-PackageFromScript src\boxstarter\Boxstarter_ChocoPackages.ps1   ChocoPackages
	New-PackageFromScript src\boxstarter\Boxstarter_PSPackages.ps1      PSPackages
	New-PackageFromScript src\boxstarter\Boxstarter_WindowsUpdates.ps1  WindowsUpdates 
	If (Test-Path $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')) {
	    . $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.ps1') -Include $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1') -Preset $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\custom\my-home.preset')  
	}
	Else {
	    Write-Output "Cant find $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')"
	}
	Install-BoxstarterPackage -PackageName ChocoPackages, PSPackages, WSLSetup #,WindowsUpdates
}
SetupWSLUsers {
	$WSLCredential = Get-Credential -Message "Enter Username and Password used for WSL Distros setup"    
	Start-Process $_ -ArgumentList "run adduser justin --gecos `"First,Last,RoomNumber,WorkPhone,HomePhone`" --disabled-password" -Wait
	Start-Process $_ -ArgumentList "run echo '$($WSLCredential.GetNetworkCredential().UserName):$($WSLCredential.GetNetworkCredential().Password)' | sudo chpasswd" -Wait
	Start-Process $_ -ArgumentList "run usermod -aG sudo justin" -Wait
	Start-Process $_ -ArgumentList "config --default-user justin" -Wait	
}
#endregion
#region
Function GUI {
	Add-Type -AssemblyName System.Windows.Forms
	[System.Windows.Forms.Application]::EnableVisualStyles()
	
	$SetupMyW10Machine               = New-Object system.Windows.Forms.Form
	$SetupMyW10Machine.ClientSize    = '409,157'
	$SetupMyW10Machine.text          = "Form"
	$SetupMyW10Machine.BackColor     = "#241734"
	$SetupMyW10Machine.TopMost       = $false
	
	$SetupW10                        = New-Object system.Windows.Forms.Button
	$SetupW10.BackColor              = "#2e2157"
	$SetupW10.text                   = "SetupW10"
	$SetupW10.width                  = 197
	$SetupW10.height                 = 42
	$SetupW10.location               = New-Object System.Drawing.Point(117,24)
	$SetupW10.Font                   = 'Microsoft Sans Serif,10'
	$SetupW10.ForeColor              = "#ff6c11"
	
	$WSLUsers                        = New-Object system.Windows.Forms.Button
	$WSLUsers.BackColor              = "#2e2157"
	$WSLUsers.text                   = "Setup WSL Users"
	$WSLUsers.width                  = 197
	$WSLUsers.height                 = 42
	$WSLUsers.location               = New-Object System.Drawing.Point(117,86)
	$WSLUsers.Font                   = 'Microsoft Sans Serif,10'
	$WSLUsers.ForeColor              = "#ff6c11"
	
	$SetupMyW10Machine.controls.AddRange(@($SetupW10,$WSLUsers))
	
	$SetupW10.Add_Click({ SetupW10 })
	$WSLUsers.Add_Click({ SetupWSLUsers })
	$SetupMyW10Machine.ShowDialog()
}
#endregion