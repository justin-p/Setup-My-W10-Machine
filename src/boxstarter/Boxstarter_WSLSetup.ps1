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
	@("$env:LOCALAPPDATA\Microsoft\WindowsApps\ubuntu1804.exe","$env:LOCALAPPDATA\Microsoft\WindowsApps\kali.exe") | ForEach-Object {
        Start-Process $_ -ArgumentList "install --root" -Wait
	}
}
SetupGitLFS
SetupWSL