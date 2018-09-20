;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv
EnvGet SystemDrive, SystemDrive
EnvGet SystemRoot, SystemRoot ; not same as A_WinDir on Windows Server
SetRegView 64

if not A_IsAdmin
{
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
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

findexefunc:="findexe"
If(IsFunc(findexefunc)) {
    Try SetACLexe := %findexefunc%(SystemDrive . "\SysUtils\SetACL.exe", "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils")
} Else {
    SetACLexe:=SystemDrive . "\SysUtils\SetACL.exe"
}

UIDEveryone := "S-1-1-0;s:y"
UIDAuthenticatedUsers := "S-1-5-11;s:y"
UIDUsers := "S-1-5-32-545;s:y"
UIDSYSTEM := "S-1-5-18;s:y"
UIDCreatorOwner := "S-1-3-0;s:y"
UIDAdministrators := "S-1-5-32-544;s:y"

Run "%SetACLexe%" -on "%ProfilesDest%" -ot file -actn ace -ace "n:%UIDUsers%;p:read;i:np;m:set" -actn ace -ace "n:%UIDEveryone%;p:read;i:np;m:set" -actn ace -ace "n:%UIDSYSTEM%;p:full" -actn ace -ace "n:%UIDAdministrators%;p:full" -actn setowner -ownr "n:%UIDSYSTEM%"

ExitApp

#Include *i %A_ScriptDir%\..\Lib\findexe.ahk
