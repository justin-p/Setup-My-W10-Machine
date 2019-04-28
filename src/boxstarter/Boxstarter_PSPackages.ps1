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
Install-Module -Name 'pester' -SkipPublisherCheck

$PSModules = @("posh-git",
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
    #"NameIT"
    "PowerShellGet",
    "PSCodeHealth",
    "PowerShellGet"
)
$PSModules | ForEach-object {
    Install-Module -Name $_ -Force
}

Enable-UAC