;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

FileAppend %A_Now% Удаление OneDrive`n, *, CP866

RegRead UninstallString, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe, UninstallString
If (UninstallString) {
    SplitPath UninstallString,, uninstDir
    ResetACL(Trim(uninstDir, """ "))
    Run %UninstallString% /qn
}

Loop Files, %LocalAppData%\Microsoft\OneDrive\*, D
{
    If (FileExist(oneDriveSetupExe := A_LoopFileLongPath "\OneDriveSetup.exe")) {
	ResetACL(A_LoopFileLongPath)
	RunWait "%oneDriveSetupExe%" /uninstall /qn, %A_LoopFileLongPath%, UseErrorLevel
    }
}
ExitApp

ResetACL(path) {
    ;sidEveryone=S-1-1-0
    sidAuthenticatedUsers=S-1-5-11
    ;sidUsers=S-1-5-32-545
    ;sidSYSTEM=S-1-5-18
    ;sidCreatorOwner=S-1-3-0
    ;sidAdministrators=S-1-5-32-544
    ;Administrators=S-1-5-32-544
    ;SYSTEM=S-1-5-18
    ;sidBackupOperators=S-1-5-32-551
    ;sidCREATOROWNER=S-1-3-0
    RunWait %SystemRoot%\System32\icacls.exe "%path%" /reset /T /C /L,,Min UseErrorLevel
    RunWait %SystemRoot%\System32\icacls.exe "%path%" /inheritance:r /C /L,,Min UseErrorLevel
    RunWait %SystemRoot%\System32\icacls.exe "%path%" /grant "*%sidAuthenticatedUsers%:(OI)(CI)M" /C /L,,Min UseErrorLevel
}

; Display Name      : Microsoft OneDrive
; Registry Name     : OneDriveSetup.exe
; Display Version   : 17.3.6816.0313
; Registry Time     : 19.10.2017 22:04:27
; Install Date      : 
; Installed For     : Install
; Install Location  : %LOCALAPPDATA%\Microsoft\OneDrive\17.3.6816.0313
; Publisher         : Microsoft Corporation
; UninstallString   : %LOCALAPPDATA%\Microsoft\OneDrive\17.3.6816.0313\OneDriveSetup.exe  /uninstall 
; Change Install String: 
; Quiet Uninstall String: 
; Comments          : 
; About URL         : 
; Update Info URL   : http://go.microsoft.com/fwlink/?LinkID=223554
; Help Link         : http://go.microsoft.com/fwlink/?LinkID=215117
; Install Source    : 
; Installer Name    : 
; Release Type      : 
; Display Icon Path : %LOCALAPPDATA%\Microsoft\OneDrive\17.3.6816.0313\OneDriveSetup.exe
; MSI Filename      : 
; Estimated Size    : 86 873 KB
; Attributes        : No Modify, No Repair
; Language          : 
; Parent Key Name   : 
; Registry Key      : HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe
