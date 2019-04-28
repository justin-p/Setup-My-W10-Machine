Function Get-ScriptDirectory  {  
    If ($hostinvocation -ne $null) { 
        Split-Path $hostinvocation.MyCommand.path 
    } 
    Else { 
        Split-Path $script:MyInvocation.MyCommand.Path 
    } 
} 
. $(Join-Path $(Get-ScriptDirectory) 'src\functions.ps1')
TestAdmin
InstallDependencies
ImportBoxstarter
New-PackageFromScript src\boxstarter\Boxstarter_ChocoPackages.ps1   ChocoPackages
New-PackageFromScript src\boxstarter\Boxstarter_PSPackages.ps1      PSPackages
New-PackageFromScript src\boxstarter\Boxstarter_WindowsUpdates.ps1  WindowsUpdates
If (Test-Path $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')) {
	. $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.ps1') -include $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1') -preset $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\custom\my-home.preset')  
} else {
	write-host "Cant find $(Join-Path $(Get-ScriptDirectory) 'src\Win10-Initial-Setup-Script\Win10.psm1')"
}
Install-BoxstarterPackage -PackageName ChocoPackages,PSPackages,WindowsUpdates