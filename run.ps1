Function Get-ScriptDirectory {
    If ($null -ne $hostinvocation) {
        Split-Path $hostinvocation.MyCommand.path 
    }
    Else {
        Split-Path $script:MyInvocation.MyCommand.Path 
    }
}
. $(Join-Path $(Get-ScriptDirectory) 'src\functions.ps1')
TestAdmin
InstallDependencies
SetupFolders
InstallKeePassPlugins
InstallDotfiles
ImportBoxstarter
New-PackageFromScript src\boxstarter\Boxstarter_ChocoPackages.ps1 ChocoPackages
New-PackageFromScript src\boxstarter\Boxstarter_PSPackages.ps1    PSPackages
If (Test-Path $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')) {
    . $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.ps1') -Include $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1') -Preset $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\custom\my-home.preset')
}
Else {
    Write-Output "Cant find $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')"
}
Install-BoxstarterPackage -PackageName ChocoPackages, PSPackages
