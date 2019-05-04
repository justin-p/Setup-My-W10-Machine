Function Get-ScriptDirectory {  
    If ($null -ne $hostinvocation) { 
        Split-Path $hostinvocation.MyCommand.path 
    }
    Else { 
        Split-Path $script:MyInvocation.MyCommand.Path 
    } 
} 
. $(Join-Path $(Get-ScriptDirectory) 'src\functions.ps1')
If (!(Test-Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\ubuntu1804.exe" )) {
    SetupWSL
    exit
}
TestAdmin
InstallDependencies
SetupFolders	
InstallKeePassPlugins
InstallFonts
InstallDotfiles
ImportBoxstarter
New-PackageFromScript src\boxstarter\Boxstarter_ChocoPackages.ps1       ChocoPackages
New-PackageFromScript src\boxstarter\Boxstarter_PSPackages.ps1          PSPackages
New-PackageFromScript .\src\boxstarter\Boxstarter_InstallWSLDistros.ps1 InstallWSLDistros
If (Test-Path $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')) {
    . $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.ps1') -Include $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1') -Preset $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\custom\my-home.preset')  
}
Else {
    Write-Output "Cant find $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')"
}
Install-BoxstarterPackage -PackageName InstallWSLDistros,ChocoPackages, PSPackages