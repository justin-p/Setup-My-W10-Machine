function SetupWSL {
	# Based on https://www.reddit.com/r/bashonubuntuonwindows/comments/a3ql25/surpress_enter_new_unix_username_for_an_automated/
	$WSLCredential = Import-Clixml -Path 'C:\_git\github\Setup-My-W10-Machine\wsl.cred'
	@("$env:LOCALAPPDATA\Microsoft\WindowsApps\ubuntu1804.exe","$env:LOCALAPPDATA\Microsoft\WindowsApps\kali.exe") | ForEach-Object {
        Start-Process $_ -ArgumentList "install --root" -Wait
        Start-Process $_ -ArgumentList "run adduser $($WSLCredential.GetNetworkCredential().UserName) --gecos `"First,Last,RoomNumber,WorkPhone,HomePhone`" --disabled-password" -Wait
		Start-Process $_ -ArgumentList "run echo '$($WSLCredential.GetNetworkCredential().UserName):$($WSLCredential.GetNetworkCredential().Password)' | sudo chpasswd" -Wait
		Start-Process $_ -ArgumentList "run usermod -aG sudo $($WSLCredential.GetNetworkCredential().UserName)" -Wait
		Start-Process $_ -ArgumentList "config --default-user $($WSLCredential.GetNetworkCredential().UserName)" -Wait
	}
	Remove-Item 'C:\_git\github\Setup-My-W10-Machine\wsl.cred'
}
SetupWSL