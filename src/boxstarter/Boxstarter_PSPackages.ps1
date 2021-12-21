Function RebootIfNeeded {
    if (Test-PendingReboot) {
        Invoke-Reboot
    }
}
$Boxstarter.RebootOk=$true
$Boxstarter.NoPassword=$true
$Boxstarter.AutoLogin=$true
Disable-UAC
Get-PackageProvider -Name NuGet -ForceBootstrap
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Remove-Module -Name 'Pester' -Force 
Install-Module -Name 'Pester' -SkipPublisherCheck -Force
$PSModules = @(
    "posh-git",
    "Get-ChildItemColor",
    "oh-my-posh",
    "ImportExcel",
    "Carbon",
    "powershell-yaml",
    "PSScriptAnalyzer",
    "PolicyFileEditor",
    "platyPS",
    "Plaster",
    "ProtectedData",
    "PowerShellGet",
    "PSCodeHealth",
    "PowerShellGet",
)
$PSModules | ForEach-object {
    Install-Module -Name $_ -Force
}
Enable-UAC
