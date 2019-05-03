Function SetupGitLFS {
    Set-Location C:\_git\github
    git clone https://github.com/justin-p/Setup-My-W10-Machine.git
    Set-Location C:\_git\github\Setup-My-W10-Machine
	git checkout -t origin/wsl-automation
	git lfs install
	git lfs fetch
	git lfs pull
	# If (Test-Path ~\.gitconfig) {Remove-Item -Path ~\.gitconfig} # Remove .gitconfig created by LFS
}
Function SetupWSL {
	# Based on https://www.reddit.com/r/bashonubuntuonwindows/comments/a3ql25/surpress_enter_new_unix_username_for_an_automated/
	ForEach ($AppX in $(Get-ChildItem 'C:\_git\github\Setup-My-W10-Machine\src\WSLAppX')) {
		Add-AppxPackage $AppX
    }	
    $WSLCredential = Get-Credential -Message "Enter Username and Password used for WSL Distros setup"    
	@("$env:LOCALAPPDATA\Microsoft\WindowsApps\ubuntu1804.exe","$env:LOCALAPPDATA\Microsoft\WindowsApps\kali.exe") | ForEach-Object {
        Start-Process $_ -ArgumentList "install --root" -Wait
        #   TODO: Rethink this setup. 
        #       A reboot is needed after WSL install. Boxstater can do this, but this clears the credential object if we ask at at the start of run.ps1
        #       Asking for a password here won't make it all 'fully automagiclly walk away and the PC is done', but sometimes you can't have your cake and eat it too.
        Start-Process $_ -ArgumentList "run adduser $($WSLCredential.GetNetworkCredential().UserName) --gecos `"First,Last,RoomNumber,WorkPhone,HomePhone`" --disabled-password" -Wait
		Start-Process $_ -ArgumentList "run echo '$($WSLCredential.GetNetworkCredential().UserName):$($WSLCredential.GetNetworkCredential().Password)' | sudo chpasswd" -Wait
		Start-Process $_ -ArgumentList "run usermod -aG sudo $($WSLCredential.GetNetworkCredential().UserName)" -Wait
		Start-Process $_ -ArgumentList "config --default-user $($WSLCredential.GetNetworkCredential().UserName)" -Wait
	}
}
SetupGitLFS
SetupWSL