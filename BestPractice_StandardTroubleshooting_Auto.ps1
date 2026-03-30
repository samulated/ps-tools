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
#endregion

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
        Write-LogLine "Updating $path"
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
        Write-LogLine "Clearing $path"
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
        Write-LogLine "Clearing $path"
        $p = $path + "\AppData\Local\VirtualStore\Program Files\Best Practice Software"
        Remove-BPFolder $p
        Write-BlankLine
    }
    Write-LogLine "END STEP 6"
    Write-BlankLine

    # STEP 7 - Delete registry keys under virtualstore

    # STEP 8 - Check/Enable Microsoft .NET Framework

    # STEP 9 - Check UAC level

    # STEP 10 (OPTIONAL) - AFTER HOURS ONLY
    # Re-register TX Control Utility - https://kb.bpsoftware.net/support/TXutility.htm

    # STEP 11 (OPTIONAL) - AFTER HOURS ONLY
    # Re-register the Document Viewer - https://kb.bpsoftware.net/support/ResolveDocumentViewer.htm

    # STEP 12 - Run RegisterAll.bat


    Write-BlankLine
    Write-LogLine "Standard troubleshooting instructions have been completed."
}
else {
    Write-LogLine "Script not running as Administrator, unable to proceed." -Level ERROR
}#>



<#
$path = "C:\Test\Apple"
Update-BPFolder $path
Write-BlankLine

$path = "C:\Test\Orange"
Update-BPFolder $path
Write-BlankLine

$path = "C:\Test\Pineapple"
Update-BPFolder $path
Write-BlankLine

$path = "C:\Test\Apple"
Remove-BPFolder $path
Write-BlankLine

Write-Output $LogBuilder.ToString()
#>

Write-LogLine "REG TEST - Update test registry key's perms"
Write-BlankLine
Update-BPRegistryKey "HKCU:\Software\_Test"
Write-LogLine "END REG TEST"
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
