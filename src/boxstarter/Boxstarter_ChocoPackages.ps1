Function MoveShortcuts {
    $Desktop = [Environment]::GetFolderPath("Desktop")
    $CommonDesktop = [Environment]::GetFolderPath("CommonDesktop")
	$DesktopShortcuts = Join-Path $Desktop 'Shortcuts'
	if (-not (Test-Path $DesktopShortcuts)) {
		[void](New-Item -ItemType directory -Path $DesktopShortcuts)
	}
	Get-ChildItem -Path $CommonDesktop -Filter '*.lnk' | Foreach {
		Move-Item -Path $_.FullName -Destination $DesktopShortcuts -ErrorAction:SilentlyContinue
	}
	Get-ChildItem -Path $Desktop -Filter '*.lnk' | Foreach {
		Move-Item -Path $_.FullName -Destination $DesktopShortcuts -ErrorAction:SilentlyContinue
	}
}
Function RebootIfNeeded {
    if (Test-PendingReboot) {
        Invoke-Reboot 
    }
}
$Boxstarter.RebootOk=$true
$Boxstarter.NoPassword=$true
$Boxstarter.AutoLogin=$true
$ChocoPackages = @(
    "php",
    "python",
    "cpu-z",
    "gpu-z",
    "hwmonitor",
    "foxitreader",
    # Checksum error "drivergenius",
    # Checksum error "spotify",
    "steam",
    "notepadplusplus",
    "markdownmonster",    
    'keepass.install',
    # Checksum error 'malwarebytes',
    "clipboardfusion",
    "vscode",
    "sharex",
    "screentogif",
    "firefox",
    "googlechrome",
    "winscp",
    "wireshark",
    "carnac",
    "lessmsi",
    "putty",
    "beyondcompare",
    "fiddler",
    "filezilla",
    "vlc",
    "rambox",
    "treesizefree",
    "google-backup-and-sync",
    "burp-suite-free-edition",
    "ccleaner",
    "ccenhancer",
    "classic-shell",
    "7zip",
    "defraggler",
    "jre8",
    "mobaxterm",
    "nmap",
    "winpcap",
    "teamviewer",
    "teracopy",
    "wkhtmltopdf",
    "bind-toolsonly",
    "wixtoolset",
    "baretail"
)
$VSCodeExtensions = @(
    'Shan.code-settings-sync'
)
$DisableStartupList = @(
        'BCClipboard'
)
Disable-UAC
$ChocoPackages | ForEach-object {
    choco config set cacheLocation "$env:LOCALAPPDATA\temp\chocolatey"
    cinst $_
    choco config set cacheLocation "$env:LOCALAPPDATA\temp\chocolatey"
}
# Install geforce-experience if we curremtly have a NVIDIA GPU
if ($(Get-WmiObject Win32_VideoController).name -match 'NVIDIA') {
	cinst geforce-experience
}
$VSCodeExtensions | ForEach-Object {
    code --install-extension $_
}
Enable-UAC
MoveShortcuts
RebootIfNeeded
