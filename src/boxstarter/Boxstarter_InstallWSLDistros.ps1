$Boxstarter.RebootOk = $true
$Boxstarter.NoPassword = $true
$Boxstarter.AutoLogin = $true
ForEach ($AppX in $(Get-ChildItem 'C:\_git\github\Setup-My-W10-Machine\src\WSLAppX')) {
    Add-AppxPackage $AppX
}