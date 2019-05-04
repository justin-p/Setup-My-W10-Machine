Function Get-ScriptDirectory {  
    If ($null -ne $hostinvocation) { 
        Split-Path $hostinvocation.MyCommand.path 
    }
    Else { 
        Split-Path $script:MyInvocation.MyCommand.Path 
    } 
} 
. $(Join-Path $(Get-ScriptDirectory) 'src\functions.ps1')
GUI