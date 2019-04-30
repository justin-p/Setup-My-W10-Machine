$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

$Modules = @( "posh-git",
    "windows-screenfetch",
    "oh-my-posh",
    "NameIt"
)
ForEach ($Module in $Modules) { 
    if(Get-Module -Name $Module -ListAvailable){
        Import-Module $Module
        If ($Module -eq 'oh-my-posh') {
            Set-Theme Paradox
        }
    If ($Module -eq 'Screenfetch') {
            Screenfetch
        }       
    }
    if(!(Get-Module $Module) ) {
        Write-Warning "Missing $($Module) support, install $($Module) with 'Install-Module $($Module)' and restart cmder."
    }
}