<#
    .SYNOPSIS
        Detects shortcuts from user's desktop. Use with Proactive Remediations or PowerShell scripts
 
        For example, detects shortcuts with the following names:
        Microsoft Teams (3).lnk
        Microsoft Teams - Copy (2).lnk
        Microsoft Teams - Copy - Copy (2).lnk
        Microsoft Teams - Copy - Copy.lnk
        Microsoft Teams - Copy.lnk

#>
[CmdletBinding()]
Param ()
    
#region Functions
Function Get-KnownFolderPath {
    <#
        .SYNOPSIS
            Gets a known folder's path using GetFolderPath.
        .PARAMETER KnownFolder
            The known folder whose path to get. Validates set to ensure only known folders are passed.
        .NOTES
            https://stackoverflow.com/questions/16658015/how-can-i-use-powershell-to-call-shgetknownfolderpath
    #>
    Param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('AdminTools', 'ApplicationData', 'CDBurning', 'CommonAdminTools', 'CommonApplicationData', 'CommonDesktopDirectory', 'CommonDocuments', 'CommonMusic', `
                'CommonOemLinks', 'CommonPictures', 'CommonProgramFiles', 'CommonProgramFilesX86', 'CommonPrograms', 'CommonStartMenu', 'CommonStartup', 'CommonTemplates', `
                'CommonVideos', 'Cookies', 'Desktop', 'DesktopDirectory', 'Favorites', 'Fonts', 'History', 'InternetCache', 'LocalApplicationData', 'LocalizedResources', 'MyComputer', `
                'MyDocuments', 'MyMusic', 'MyPictures', 'MyVideos', 'NetworkShortcuts', 'Personal', 'PrinterShortcuts', 'ProgramFiles', 'ProgramFilesX86', 'Programs', 'Recent', `
                'Resources', 'SendTo', 'StartMenu', 'Startup', 'System', 'SystemX86', 'Templates', 'UserProfile', 'Windows')]
        [System.String] $KnownFolder
    )
    [Environment]::GetFolderPath($KnownFolder)
}
#endregion
    
# Get shortcuts from the Public desktop
try {
    $Path = Get-KnownFolderPath -KnownFolder "Desktop"
    $Filter = "(.*Copy.*lnk$)|(.*\(\d\).*lnk$)"
    $Shortcuts = Get-ChildItem -Path $Path | Where-Object { $_.Name -match $Filter }
}
catch {
    Write-Host "Failed when enumerating shortcuts at: $Path."
    Write-Host $_.Exception.Message
    Exit 1
}    

# If $Shortcuts > 1
# Output all shortcuts in a list with line breaks in a single output
If ($Shortcuts.Count -gt 0) {
    ForEach ($Shortcut in $Shortcuts) {
        $Output += "$($Shortcut.FullName)`n"
    }
    Write-Host "Found shortcuts:`n$Output"
    Exit 1
}
    
# All settings are good exit cleanly
Write-Host "No shortcuts found at: $Path."
Exit 0