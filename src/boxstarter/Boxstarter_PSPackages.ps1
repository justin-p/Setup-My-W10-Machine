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
$PSModules = @("posh-git",
    "Get-ChildItemColor",
    "oh-my-posh",
    "VMware.PowerCLI",
    "ImportExcel",
    "Carbon",
    "powershell-yaml",
    "DockerMsftProvider",
    "PSScriptAnalyzer",
    "PolicyFileEditor",
    "platyPS",
    "Plaster",
    "ProtectedData",
    # "NameIT"
    "PowerShellGet",
    "PSCodeHealth",
    "PowerShellGet",
    "windows-screenfetch"
)
$PSModules | ForEach-object {
    Install-Module -Name $_ -Force
}
Enable-UAC
