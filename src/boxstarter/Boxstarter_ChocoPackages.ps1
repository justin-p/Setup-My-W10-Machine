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
Function StartupItems {
    Function New-FileShortcut {
        <#
        .SYNOPSIS
           Create Windows shortcuts
        .DESCRIPTION
            Creates shortcuts of the Target in the given location. 
            Given locations can either be the full path, or just the name in which
            case its created on the current path.
            If just the target path is given, it creates a shortcut with the same 
            name as the target in the current path.
    
            All parameters other than the Target is optional.
        .EXAMPLE
            New-FileShortcut "C:\Windows\notepad.exe"
            Creates notepad.lnk in the current folder
        .EXAMPLE
            New-FileShortcut -Target "C:\Windows\notepad.exe" -Name "Notepad Shortcut"
            Creates "Notepad Shortcut.lnk" in the current folder
        .EXAMPLE
            New-FileShortcut -Target "C:\Windows\notepad.exe" -FullPath "D:\Notepad Shortcut.lnk"
    
            Creates shortcut: "D:\Notepad Shortcut.lnk"
        #>
    
        [CmdletBinding()]
        param(
            [Parameter(Position = 1)]
            [string] $Name,
            [Parameter(Position = 2)]
            [string] $FullPath,
            [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
            [ValidateScript( { Test-Path -IsValid -PathType Leaf -LiteralPath $_ })]
            [string] $Target,
            [Parameter()]
            [ValidateNotNull()]
            [string] $IconLocation,
            [Parameter()]
            [ValidateNotNull()]
            [string] $Arguments,
            [Parameter()]
            [ValidateScript( { Test-Path -IsValid -PathType Container -LiteralPath $_ })]
            [string] $WorkingDirectory,

            [Parameter()]
            [string] $Description
        )

        process {
            $shell = New-Object -ComObject WScript.Shell
            $path = ''
            if ($Name -and -not $FullPath) {
                $path = "$($pwd.Path)\$($Name)"
                if (-not $path.EndsWith('.lnk')) {
                    $path += '.lnk'
                }
            }
            elseif ($FullPath) {
                $path = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($FullPath)
                $parent = Split-Path $path -Parent
                if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
                    mkdir $parent
                }
            }
            else {
                $path = "$($pwd.Path)\$([System.IO.Path]::GetFileNameWithoutExtension($Target)).lnk"
            }
            $shortcut = $shell.CreateShortcut($path)
            $shortcut.TargetPath = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($Target)
            if ($IconLocation) {
                $shortcut.IconLocation = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($IconLocation)
            }
            if ($Arguments) {
                $shortcut.Arguments = $Arguments
            }
            if ($Description) {
                $shortcut.Description = $Description
            }
            if ($WorkingDirectory) {
                $shortcut.WorkingDirectory = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($WorkingDirectory)
            }
            $shortcut.Save()
        }
    }    
    function ShortCutObj {
        $ShortCut = @()
        $ShortCut += $(New-Object -TypeName PSObject -Property @{Target = "$("$env:SystemDrive\tools\Cmder\Cmder.exe")"; FullPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Cmder.lnk" })
        $ShortCut += $(New-Object -TypeName PSObject -Property @{Target = "$("$env:ChocolateyInstall\lib\keypirinha\tools\Keypirinha\Keypirinha.exe")"; FullPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Keypirinha.lnk" })        
        Return $ShortCut
    }
    Function CreateShortcut {
        ShortCutObj | ForEach-Object {
            New-FileShortcut -Target $_.Target -FullPath $_.FullPath 
        }
    }
    CreateShortcut
}
$Boxstarter.RebootOk = $true
$Boxstarter.NoPassword = $true
$Boxstarter.AutoLogin = $true
$ChocoPackages = @(
    "cmder",
    "keypirinha"
    "php",
    "python",
    "cpu-z",
    "gpu-z",
    "hwmonitor",
    "foxitreader",
    # Checksum error "drivergenius"
    "spotify",
    "steam",
    "notepadplusplus",
    "markdownmonster",    
    'keepass.install',
    # Checksum error 'malwarebytes'
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
    "baretail",
    "dotnetcore",
    "Etcher"
)
$VSCodeExtensions = @(
    'Shan.code-settings-sync'
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
StartupItems
RebootIfNeeded
