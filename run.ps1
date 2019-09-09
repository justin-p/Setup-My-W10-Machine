Function Get-ScriptDirectory {  
    If ($null -ne $hostinvocation) { 
        Split-Path $hostinvocation.MyCommand.path 
    }
    Else { 
        Split-Path $script:MyInvocation.MyCommand.Path 
    } 
} 
. $(Join-Path $(Get-ScriptDirectory) 'src\functions.ps1')
If (Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\ubuntu1804.exe") {
    SetupWSL
    Exit
}
TestAdmin
$WSLCredential = Get-Credential -Message "Enter Username and Password used for WSL Distros setup"
$WSLCredential | Export-Clixml -Path 'C:\_git\github\Setup-My-W10-Machine\wsl.cred'
InstallDependencies
SetupFolders	
InstallKeePassPlugins
InstallFonts
InstallDotfiles
ImportBoxstarter
SetupGitLFS
New-PackageFromScript src\boxstarter\Boxstarter_ChocoPackages.ps1     ChocoPackages
New-PackageFromScript src\boxstarter\Boxstarter_PSPackages.ps1        PSPackages
New-PackageFromScript src\boxstarter\Boxstarter_InstallWSLDistros.ps1 InstallWSLDistros
New-PackageFromScript src\boxstarter\Boxstarter_SetupWSLDistros.ps1   SetupWSLDistros
If (Test-Path $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')) {
    . $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.ps1') -Include $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1') -Preset $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\custom\my-home.preset')  
}
Else {
    Write-Output "Cant find $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')"
}
Install-BoxstarterPackage -PackageName InstallWSLDistros, SetupWSLDistros, ChocoPackages, PSPackages