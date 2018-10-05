;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EnvGet SystemDrive, SystemDrive

profilesListKey := "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"

If (!A_IsAdmin) {
    InteractiveRunAs()
    ExitApp
}

Try RegRead ProfilesDirectory, %profilesListKey%, ProfilesDirectory.bak
Catch exc
    e := exc
If (ErrorLevel || !ProfilesDirectory)
    Panic(e, "Резервная копия ProfilesDirectory не прочитана из «" profilesListKey ": ProfilesDirectory.bak»")

Try RegWrite REG_EXPAND_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory, %ProfilesDirectory%
Catch exc
    Panic(exc, "Путь к папке профилей не записан")
RegDelete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList, ProfilesDirectory.bak

#include %A_LineFile%\..\..\Lib\Panic.ahk
#include %A_LineFile%\..\..\Lib\InteractiveRunAs.ahk
