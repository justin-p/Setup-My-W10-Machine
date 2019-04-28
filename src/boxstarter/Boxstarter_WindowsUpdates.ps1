Function RebootIfNeeded {
    if (Test-PendingReboot) {
        Invoke-Reboot 
    }
}
Function InstallWindowsUpdates {
    Install-WindowsUpdate -getUpdatesFromMS -acceptEula
}
$Boxstarter.RebootOk=$true
$Boxstarter.NoPassword=$true
$Boxstarter.AutoLogin=$true
Enable-MicrosoftUpdate
Start-Sleep -s 5
InstallWindowsUpdates