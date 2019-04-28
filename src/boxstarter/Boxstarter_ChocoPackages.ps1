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
Function Disable-Startups 
{
    [CmdletBinding()]
    Param (
        [parameter(DontShow = $true)]
        $32bit = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        [parameter(DontShow = $true)]
        $32bitRunOnce = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        [parameter(DontShow = $true)]
        $64bit = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
        [parameter(DontShow = $true)]
        $64bitRunOnce = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\RunOnce",
        [parameter(DontShow = $true)]
        $currentLOU = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        [parameter(DontShow = $true)]
        $currentLOURunOnce = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        [parameter()]
        [PSCustomObject]$DisableList
    )
    begin {
        New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS | 
        out-null
        $startups = Get-CimInstance Win32_StartupCommand | 
        Select-Object Name,Location
    }
    process {
        Get-Item -path $32bit,$32bitRunOnce,$64bit,$64bitRunOnce,$currentLOU,$currentLOURunOnce |
        Where-Object {$_.ValueCount -ne 0} | 
        Select-Object  @{Name = 'Location';Expression = {$_.name -replace 'HKEY_LOCAL_MACHINE','HKLM' -replace 'HKEY_CURRENT_USER','HKCU'}},
        @{Name = 'Name';Expression = {$_.Property}} | 
        %{
            ForEach($disableListName in $disableList) {
                If ($_.Name -contains $disableListName) {
                    if ($_.Location -match 'HKLM') {
                        Remove-ItemProperty -Path ($_.Location -Replace 'HKLM\\','HKLM:\' ) -Name $disableListName
                    } ElseIf ($_.Location -match 'HKCU') {
                        Remove-ItemProperty -Path ($_.Location -Replace 'HKCU\\','HKCU:\' ) -Name $disableListName
                    }
                }
                Else { 
                    Write-Warning -Message "$disableListName not found in registry" 
                }
            }
        }
    }
    end {

    }
}
$Boxstarter.RebootOk=$true
$Boxstarter.NoPassword=$true
$Boxstarter.AutoLogin=$true
$ChocoPackages = @(
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
    "classic-shell",
    "7zip",
    "hwmonitor",
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
$VSCodeExtensions | ForEach-Object {
    code --install-extension $_
}
Enable-UAC
MoveShortcuts
Disable-Startups -DisableList $DisableStartupList
RebootIfNeeded