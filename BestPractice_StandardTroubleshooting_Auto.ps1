using namespace System.Security.AccessControl
using namespace System.Security.Principal
using namespace System.Text


$LogBuilder = [StringBuilder]::new()

#region Functions
# Parking lot for all of my functions

function Test-BPIsAdmin {
    $identity = [WindowsIdentity]::GetCurrent()
    $principal = New-Object WindowsPrincipal $identity
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Write-LogLine {
    param (
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','ACTION')]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    [void]$LogBuilder.AppendLine("[$timestamp] [$Level] $Message")
}

function Write-BlankLine {
    [void]$script:LogBuilder.AppendLine()
}

function Get-BPAllUserPaths {
    $exclusions = @("Public", "Default", "Administrator")
    $folders = Get-ChildItem -Path "C:\Users" -Directory -Exclude $exclusions
    
    $users = @()
    foreach ($folder in $folders) {
        $users += "C:\Users\" + $folder.Name
    }

    return $users
}

#region BPFolder Functions
# Functions to get/set permissions for and entirely delete folders

# Checks if folder in question exists
function Get-BPFolderExists {
    param (
        [string[]]$FilePath
    )

    return (Test-Path -Path $FilePath)
}

# Checks if folder already has Full Control access for Everyone
function Get-BPFolderPermission {
    param (
        [string[]]$FilePath
    )

    $Acl = Get-Acl -LiteralPath $FilePath
    
    $hasFullControl = $acl.Access | Where-Object {
        $_.IdentityReference.Translate([SecurityIdentifier]) -eq ([SecurityIdentifier]::new([SecurityIdentifier]("S-1-1-0"))) -and
        $_.AccessControlType -eq 'Allow' -and
        ($_.FileSystemRights -band [FileSystemRights]::FullControl) -eq [FileSystemRights]::FullControl
    }

    return $hasFullControl
}

# Sets the Access Control permission for given filepath to be Full Control for Everyone
function Set-BPFolderPermission {
    param (
        [string[]]$FilePath
    )

    $Acl = Get-Acl -LiteralPath $FilePath
    $Ace = [FileSystemAccessRule]::new(
        [SecurityIdentifier]::new("S-1-1-0"),
        [FileSystemRights]::FullControl,
        [InheritanceFlags]::ContainerInherit -bor [InheritanceFlags]::ObjectInherit,
        [PropagationFlags]::None,
        [AccessControlType]::Allow
    )
    $Acl.SetAccessRule($Ace)
    Set-Acl -LiteralPath $FilePath -AclObject $Acl
}

function Update-BPFolder {
    param (
        [string[]]$FilePath
    )

    Write-LogLine "Starting check for: $FilePath"

    if (Get-BPFolderExists($FilePath)) {
        if(Get-BPFolderPermission($FilePath)) {
            Write-LogLine "Folder already has requested permissions."
        }
        else {
            Write-LogLine "Folder is missing 'Full Access' permission for 'Everyone'." -Level WARN
            Set-BPFolderPermission($FilePath)
            Write-LogLine "Successfully updated permission." -Level ACTION
        }
    }
    else {
        Write-LogLine "Path does not exist." -Level ERROR
    }

    Write-LogLine "Finished check for: $FilePath"
}

function Clear-BPFolderContents {
    param (
        [string[]]$FilePath
    )

    Write-LogLine "Starting check for: $FilePath"
    if (Get-BPFolderExists($FilePath))
    {
        Remove-Item -Path "$FilePath\*" -Recurse
        Write-LogLine "Cleared contents of folder successfully" -Level ACTION
    }
    else {
        Write-LogLine "Folder does not exist." -Level ERROR
    }
    Write-LogLine "Finished check for: $FilePath"
}
function Remove-BPFolder {
    param (
        [string[]]$FilePath
    )

    Write-LogLine "Starting check for: $FilePath"
    if (Get-BPFolderExists($FilePath))
    {
        Remove-Item -Path "$FilePath" -Recurse
        Write-LogLine "Removed folder successfully" -Level ACTION
    }
    else {
        Write-LogLine "Folder does not exist." -Level ERROR
    }
    Write-LogLine "Finished check for: $FilePath"
}
#endregion

#region BPRegistryKey Functions
function Get-BPRegistryKeyExists {
    param (
        [string[]]$RegistryPath
    )

    return (Test-Path -Path $RegistryPath)
}

function Get-BPRegistryKeyPermission {
    param (
        [string[]]$RegistryPath
    )
    $Acl = Get-Acl -Path $RegistryPath
    
    $hasFullControl = $acl.Access | Where-Object {
        $_.IdentityReference.Translate([SecurityIdentifier]) -eq ([SecurityIdentifier]::new([SecurityIdentifier]("S-1-1-0"))) -and
        $_.AccessControlType -eq 'Allow' -and
        ($_.RegistryRights -band [RegistryRights]::FullControl) -eq [RegistryRights]::FullControl
    }

    return $hasFullControl
}

function Set-BPRegistryKeyPermission {
    param (
        [string[]]$RegistryPath
    )

    $Acl = Get-Acl -Path $RegistryPath
    $Ace = [RegistryAccessRule]::new(
        [SecurityIdentifier]::new("S-1-1-0"),
        [RegistryRights]::FullControl,
        [InheritanceFlags]::ContainerInherit -bor [InheritanceFlags]::ObjectInherit,
        [PropagationFlags]::None,
        [AccessControlType]::Allow
    )
    $Acl.SetAccessRule($Ace)
    Set-Acl -Path $RegistryPath -AclObject $Acl
}
function Update-BPRegistryKey {
    param (
        [string[]]$RegistryPath
    )

    Write-LogLine "Starting check for: $RegistryPath"

    if (Get-BPRegistryKeyExists($RegistryPath)) {
        if(Get-BPRegistryKeyPermission($RegistryPath)) {
            Write-LogLine "Registry key already has requested permissions."
        }
        else {
            Write-LogLine "Registry key is missing 'Full Access' permission for 'Everyone'." -Level WARN
            Set-BPRegistryKeyPermission($RegistryPath)
            Write-LogLine "Successfully updated permission." -Level ACTION
        }
    }
    else {
        Write-LogLine "Path does not exist." -Level ERROR
    }

    Write-LogLine "Finished check for: $RegistryPath"
}

function Remove-BPRegistryKey {
    param (
        [string[]]$RegistryPath
    )

    Write-LogLine "Starting check for: $RegistryPath"
    if (Get-BPRegistryKeyExists($RegistryPath))
    {
        Remove-Item -Path "$RegistryPath" -Recurse
        Write-LogLine "Removed key successfully" -Level ACTION
    }
    else {
        Write-LogLine "Key does not exist." -Level ERROR
    }
}

# Search under path for keys matching the search term
function Find-BPRegistryKeySubkey {
    param (
        [string[]]$RegistryPath,
        [string[]]$SearchTerm
    )

    $keys = Get-ChildItem -Path $RegistryPath -Recurse | Where-Object { $_.Name -like "*$SearchTerm*" }
    if ($keys.Count -eq 0) {
        Write-LogLine "No '$SearchTerm' subkeys exist below '$RegistryPath'." -Level ERROR
        return $keys
    }

    $c = $keys.Count
    Write-LogLine "Found $c subkeys matching the search term '$SearchTerm'."
    return $keys
}
#endregion

function Get-DotNET4p8Installed {
    $release = Get-ItemPropertyValue -LiteralPath "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -Name Release
    switch ($release) {
        { $_ -ge 533320 } { $version = '4.8.1 or later'; break }
        { $_ -ge 528040 } { $version = '4.8'; break }
        { $_ -ge 461808 } { $version = '4.7.2'; break }
        { $_ -ge 461308 } { $version = '4.7.1'; break }
        { $_ -ge 460798 } { $version = '4.7'; break }
        { $_ -ge 394802 } { $version = '4.6.2'; break }
        { $_ -ge 394254 } { $version = '4.6.1'; break }
        { $_ -ge 393295 } { $version = '4.6'; break }
        { $_ -ge 379893 } { $version = '4.5.2'; break }
        { $_ -ge 378675 } { $version = '4.5.1'; break }
        { $_ -ge 378389 } { $version = '4.5'; break }
        default { $version = $null; break }
    }
    if ($version) {
        if ($version -eq '4.8') {
            Write-LogLine "Confirmed that .NET Framework 4.8 is installed."
        }
        else {
            Write-LogLine ".NET Framework 4.8 is not installed, detected $version instead!" -Level ERROR
        }
    }
    else {
        Write-LogLine ".NET Framework 4.5 or later is not detected." -Level ERROR
    }
}

function Get-DotNET3p5Installed {
    $install = Get-ItemPropertyValue -LiteralPath "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" -Name Install
    
    if ($install -eq 1)
    {
        Write-LogLine ".NET Framework 3.5 was detected."
    }
    else
    {
        Write-LogLine ".NET Framework 3.5 was not detected!" -Level ERROR
    }
}

function Get-BPUACLevel {
    $prop = Get-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System
    $level = $prop.ConsentPromptBehaviorUser
    
    Write-LogLine "Current UAC level is $level."
}

#endregion

#region Main
# The main functional part of this script

<#
if (Test-BPIsAdmin) {
    Write-LogLine "Confirmed script is running with Admin permissions."
    Write-LogLine "Beginning step-by-step instructions."
    Write-BlankLine

    # STEP 1 - Change Best Practice folder permissions
    Write-LogLine "STEP 1 - Change Best Practice folder permissions"
    Write-BlankLine
    Update-BPFolder "C:\Program Files\Best Practice Software"
    Write-LogLine "END STEP 1"
    Write-BlankLine

    # STEP 2 - Change Temp folder permissions for all users
    Write-LogLine "STEP 2 - Change Temp folder permissions for all users"
    Write-BlankLine
    foreach ($path in Get-BPAllUserPaths) {
        Write-LogLine "Updating temp folder perms for $path"
        $p = $path + "\AppData\Local\Temp"
        Update-BPFolder $p
        Write-BlankLine
    }
    Write-LogLine "END STEP 2"
    Write-BlankLine

    # STEP 3 - Clear the temp directory
    Write-LogLine "STEP 3 - Change Temp folder contents for all users"
    Write-BlankLine
    foreach ($path in Get-BPAllUserPaths) {
        Write-LogLine "Clearing temp folder for $path"
        $p = $path + "\AppData\Local\Temp"
        Clear-BPFolderContents $p
        Write-BlankLine
    }
    Write-LogLine "END STEP 3"
    Write-BlankLine

    # STEP 4 - Add full permissions to the WebView2 folder
    Write-LogLine "STEP 4 - Change Best Practice folder permissions"
    Write-BlankLine
    Update-BPFolder "C:\Program Files (x86)\Microsoft\EdgeWebView\Application"
    Write-LogLine "END STEP 4"
    Write-BlankLine

    # STEP 5 - Change Registry key permissions
    Write-LogLine "STEP 5 - Update registry key permissions"
    Write-BlankLine
    Update-BPRegistryKey "HKCU:\SOFTWARE\Best Practice Software\Best Practice"
    Update-BPRegistryKey "HKLM:\SOFTWARE\WOW6432Node\Best Practice Software"
    Write-LogLine "END STEP 5"
    Write-BlankLine
    
    # STEP 6 - Delete folders under virtualstore
    Write-LogLine "STEP 6 - Delete BPS folder in Virtual Store"
    Write-BlankLine
    foreach ($path in Get-BPAllUserPaths) {
        Write-LogLine "Deleting BP folder from virtual store of $path"
        $p = $path + "\AppData\Local\VirtualStore\Program Files\Best Practice Software"
        Remove-BPFolder $p
        Write-BlankLine
    }
    Write-LogLine "END STEP 6"
    Write-BlankLine

    # STEP 7 - Delete registry keys under virtualstore
    Write-LogLine "STEP 7 - Search for and delete Best Practice subkeys under the virtualstore registry keys"
    Write-BlankLine

    Write-LogLine "Searching under Local Machine (HKLM)"
    $keys = Find-BPRegistryKeySubKey("HKLM:\Software", "virtualstore")
    if ($keys.Count -ne 0) {
        foreach($key in $keys) {
            $subkeys = Find-BPRegistryKeySubkey($k.PSPath, "Best Practice")
            if ($subkeys.Count -ne 0) {
                foreach ($skey in $subkeys) {
                    Remove-BPFolder $skey.PSPath
                    Write-BlankLine
                }
            }
            Write-BlankLine
        }
    }
    Write-BlankLine

    Write-LogLine "Searching under Current User (HKCU)"
    $keys = Find-BPRegistryKeySubKey("HKCU:\Software", "virtualstore")
    if ($keys.Count -ne 0) {
        foreach($key in $keys) {
            $subkeys = Find-BPRegistryKeySubkey($k.PSPath, "Best Practice")
            if ($subkeys.Count -ne 0) {
                foreach ($skey in $subkeys) {
                    Remove-BPRegistryKey $skey.PSPath
                    Write-BlankLine
                }
            }
            Write-BlankLine
        }
    }
    Write-LogLine "END STEP 7"
    Write-BlankLine

    # STEP 8 - Check/Enable Microsoft .NET Framework
    Write-LogLine "STEP 8 - Check that .NET Framework 3.5 & 4.8 are installed"
    Get-DotNET3p5Installed
    Get-DotNET4p8Installed
    Write-LogLine "END STEP 8"
    Write-BlankLine

    # STEP 9 - Check UAC level
    Write-LogLine "STEP 9 - Confirm UAC level is 2 or 3"
    Get-BPUACLevel
    Write-LogLine "END STEP 9"
    Write-BlankLine

    # STEP 10 (OPTIONAL) - AFTER HOURS ONLY
    # Re-register TX Control Utility - https://kb.bpsoftware.net/support/TXutility.htm
    Write-LogLine "STEP 10 - Optional, run after hours only!"
    # TODO:Implement re-register document viewer
    Write-BlankLine

    # STEP 11 (OPTIONAL) - AFTER HOURS ONLY
    # Re-register the Document Viewer - https://kb.bpsoftware.net/support/ResolveDocumentViewer.htm
    Write-LogLine "STEP 11 - Optional, run after hours only! Re-register Document Viewer"
    # TODO:Implement re-register document viewer
    Write-BlankLine

    # STEP 12 - Run RegisterAll.bat
    Write-LogLine "STEP 12 - Run RegisterAll.bat"
    Start-Process -FilePath "C:\Program Files\Best Practice Software\BPS\BPSupport\RegsiterAll.bat" -Wait
    Write-LogLine "END STEP 12"
    Write-BlankLine
    Write-BlankLine
    Write-LogLine "Standard troubleshooting instructions have been completed."
}
else {
    Write-LogLine "Script not running as Administrator, unable to proceed." -Level ERROR
}
#>


Write-LogLine "CHECK TEST - Running the checks"
Write-BlankLine
Get-DotNET3p5Installed
Get-DotNET4p8Installed
Get-BPUACLevel
Write-BlankLine

Write-Output $LogBuilder.ToString()

#endregion

#region Notes
# Things that will be handy to reference

# Boilerplate WinForm
<#
Add-Type -assembly System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Test Form"
$form.Size = New-Object System.Drawing.Size(300, 200)
$form.StartPosition = "CenterScreen"

# Add Button
$button = New-Object System.Windows.Forms.Button
$button.Text = "Click Me"
$button.Location = New-Object System.Drawing.Point(100, 100)
$button.Size = New-Object System.Drawing.Size(75, 23)

# Define the button click action
$button.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Hello, World!")
})

# Add the button to the form controls
$form.Controls.Add($button)

# Display the form
$form.ShowDialog()
#>

#endregion
