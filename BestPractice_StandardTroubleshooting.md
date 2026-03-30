STEP 0.1
Check for Administrator elevation, fail early if not present

STEP 0.2
Check whether running on AVD, these steps are for the workstation, not for the BP server

STEP 1
Change Best Practice folder permissions
1.1 - C:\Program Files\Best Practice Software
1.2 - Change Security for this folder
1.3 - Add 'Everyone' group with 'Full' control permission
1.Z - Update log with: whether the folder exists, whether the permission had to be updated, and a check of the permission afterwards

STEP 2
Change Temp folder permissions
2.1 - C:\Users\%Userprofile%\AppData\Local\Temp
2.2 - Change Security for this folder
2.3 - Add 'Everyone' group with 'Full' control permission
2.3.Z - Update log with: whether folder exists, whether permission had to be updated, and a check
2.4 - Repeat for all User profiles in C:\Users

STEP 3
Clear the temp directory
3.1 - clear contents of C:\Users\%Userprofile%\AppData\Local\Temp

STEP 4
Add full permissions to the WebView2 folder
4.1 - C:\Program Files (x86)\Microsoft\EdgeWebView\Application
4.2 - Change Security for this folder
4.3 - Add 'Everyone' group with 'Full' control permission
4.Z - Update log with: whether folder exists, whether the permission had to updated, and a check

STEP 5
Change Registry key permissions
5.1 - Open Regedit (I think regedit actions can be scripted through powershell using a particular module anyway)
5.2 - Computer\HKEY_CURRENT_USER\SOFTWARE\Best Practice Software\Best Practice
5.3 - Update Permissions for this key
5.4 - Add 'Everyone' group with 'Full' control permission
5.5 - Repeat 5.3 and 5.4 for Computer\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Best Practice Software
5.Z - Update log with: whether keys exist, whether permission had to be updated, and a check

STEP 6
Delete folders under virtualstore
6.1 C:\Users\%userprofile%\AppData\Local\VirtualStore\Program Files
6.2 If there is a Best Practice Software folder here, delete it
6.Z Update log with: whether there was a folder, that it was deleted

STEP 7
Delete registry keys under virtualstore
7.1 Open Regedit
7.2 \HKEY_LOCAL_MACHINE\Software
7.3 Find... "virtualstore" keys
7.4 For Each found key
7.4.1 Check if 'Best Practice' related keys are here, Delete them
7.4.2 Check if key 'ODBC.INI' is here, 'if there are any Best Practice related keys under ODBC.INI delete them'
7.4.2.A  I don't know what they are actually asking here, so I'll probably just throw something as a dialog to indicate it was found and requires manual intervention
7.5 Repeat this for \HKEY_CURRENT_USER\Software
7.Z Update log ???

STEP 8
Check/Enable Microsoft .NET Framework
8.1 - Make sure that .NET 4.8 and 3.5 are fully installed and enabled for Turn Windows Features On or Off
8.2 - Make sure that all .NET Framework features are ticket and enabled for Turn Windows Features On or Off

STEP 9
Check UAC level
9.1 Check UAC level from 'Change User Account Control Settings'
9.2 Make sure it's set to one of the 'middle two' levels of access
9.Z Log what was set, and whether it was change

STEP 10 (OPTIONAL)
Re-register TX Control Utility - https://kb.bpsoftware.net/support/TXutility.html

STEP 11 (OPTIONAL)
Re-register the Document Viewer - https://kb.bpsoftware.net/support/ResolveDocumentViewer.html
11.0.1 - This will launch an external installer, will have to see if there's a way to wait for the installer? Maybe prompt for what happened?
11.0.2 - This MUST be done when everyone is off the server.
11.1 - Launch C:\Program Files\Best Practice Software\Document Viewer Tool.exe as Administrator
11.2 - Clean Registry, wait for '-- Registry clean complete --' response
11.3 - Register Files, wait for '-- Finished registering files --' response
11.4 - Check File Registrations, wait for '-- Finished checking file registrations --' response
11.5 - Look at the log to see if the five files above '-- Finished checking file registrations --' report as 'registered ok'
11.6 - Close. If any issues during this install, raise to BP Sofwater Support. Otherwise continue.
11.Z - Record as done I guess? Might have a prompt to autorecord whether it passed properly or not

STEP 12
Run RegisterAll.bat
12.1 C:\Program Files\Best Practice Software\BPS\BPSupport
12.2 Run RegisterAll.bat as administrator
12.Z Record that it ran
