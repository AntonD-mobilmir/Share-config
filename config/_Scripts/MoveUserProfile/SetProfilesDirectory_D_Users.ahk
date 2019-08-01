;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
EnvGet SystemDrive, SystemDrive
EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server
EnvGet Unattended, Unattended
If (!Unattended) {
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    Unattended := RunInteractiveInstalls=="0"
}
SetRegView 64

If (!A_IsAdmin) {
    If (!Unattended) {
        ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
        Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    }
    ExitApp
}

ProfilesDest:="D:\Users"

RegRead ProfilesDirectory, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory

FileCreateDir %ProfilesDest%
If (!FileExist(ProfilesDest)) {
    If (RunInteractiveInstalls != "0")
	MsgBox 16, %A_ScriptName%, Не удалось создать папку "%ProfilesDest%".`nПродолжение невозможно`, папка профилей останется "%ProfilesDirectory%"., 300
    Exit
}

If A_OSVersion in WIN_2003,WIN_XP,WIN_2000
{
    Run %SystemDrive%\SysUtils\xln.exe -n "c:\Documents and Settings\All Users" "%ProfilesDest%\All Users"
    Run %SystemDrive%\SysUtils\xln.exe -n "c:\Documents and Settings\Default User" "%ProfilesDest%\Default User"
}

If ( ProfilesDirectory = ProfilesDest ) {
    TrayTip %A_ScriptName%, Каталог профилей уже "%ProfilesDest%".`nБудет настроен общий доступ и параметры безопасности.,,0x31
} Else {
    RegWrite REG_EXPAND_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory.bak, %ProfilesDirectory%
    RegWrite REG_EXPAND_SZ, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory, %ProfilesDest%
}

RunWait %comspec% /C "%SystemRoot%\System32\net.exe SHARE Users /DELETE /Y & %SystemRoot%\System32\net.exe SHARE Users="%ProfilesDest%" /GRANT:Everyone`,FULL & %SystemRoot%\System32\net.exe SHARE Users="%ProfilesDest%" /GRANT:Все`,FULL & %SystemRoot%\System32\net.exe SHARE Users="%ProfilesDest%""

;RunWait %SystemRoot%\System32\net.exe SHARE Users$ /DELETE
;RunWait %SystemRoot%\System32\net.exe SHARE Users$="%ProfilesDirectory%" /GRANT:Everyone`,FULL
;RunWait %SystemRoot%\System32\net.exe SHARE Users$="%ProfilesDirectory%" /GRANT:Все`,FULL
;RunWait %SystemRoot%\System32\net.exe SHARE Users$="%ProfilesDirectory%"

SIDEveryone=S-1-1-0
SIDAuthenticatedUsers=S-1-5-11
SIDUsers=S-1-5-32-545
SIDSYSTEM=S-1-5-18
SIDCreatorOwner=S-1-3-0
SIDAdministrators=S-1-5-32-544

findexefunc:="findexe"
If(IsFunc(findexefunc))
    Try SetACLexe := %findexefunc%(SystemDrive . "\SysUtils\SetACL.exe", "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils")
If (SetACLexe) {
    RunWait "%SetACLexe%" -on "%ProfilesDest%" -ot file -actn ace -ace "n:%SIDUsers%;s:y;p:read;i:np;m:set" -actn ace -ace "n:%SIDEveryone%;s:y;p:read;i:np;m:set" -actn ace -ace "n:%SIDSYSTEM%;s:y;p:full" -actn ace -ace "n:%SIDAdministrators%;s:y;p:full" -actn setowner -ownr "n:%SIDSYSTEM%;s:y"
} Else {
    RunWait %SystemRoot%\System32\icacls.exe "%ProfilesDest%" /grant:r "*%SIDUsers%:(NP)(RX)" /grant:r "*%SIDEveryone%:(NP)(RX)" /grant:r "*%SIDSYSTEM%:F(OI)(CI)" "%SIDAdministrators%:F(OI)(CI)" /C /L
    ;RunWait %SystemRoot%\System32\icacls.exe "%ProfilesDest%" /setowner "*%SIDSYSTEM%" /C /L
        ;>%SystemRoot%\System32\icacls.exe "%ProfilesDest%" /setowner "*%SIDSYSTEM%" /C /L
        ;test: This security ID may not be assigned as the owner of this object.
        ;Successfully processed 0 files; Failed processing 1 files
}

ExitApp

#include *i %A_LineFile%\..\..\Lib\findexe.ahk
#include *i %A_LineFile%\..\..\Lib\InteractiveRunAs.ahk
