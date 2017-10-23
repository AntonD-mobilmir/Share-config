;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA

FileAppend %A_Now% Удаление OneDrive`n, *, CP866

RegRead UninstallString, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe, UninstallString
If (UninstallString) {
    CheckAdminRestartIfNot()
    Run %UninstallString% /qn
}

Loop Files, %LocalAppData%\Microsoft\OneDrive\*, D
{
    If (FileExist(oneDriveSetupExe := A_LoopFileLongPath "\OneDriveSetup.exe")) {
	CheckAdminRestartIfNot()
	RunWait "%oneDriveSetupExe%" /uninstall /qn, %A_LoopFileLongPath%
    }
}
ExitApp

CheckAdminRestartIfNot() {
    If (!A_IsAdmin) {
	Run % "*RunAs " . DllCall( "GetCommandLine", "Str" ),,UseErrorLevel  ; Requires v1.0.92.01+
	ExitApp
    }
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
