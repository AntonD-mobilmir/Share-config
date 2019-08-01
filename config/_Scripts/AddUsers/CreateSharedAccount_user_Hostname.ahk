;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

EnvGet Unattended, Unattended
If (!Unattended) {
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    Unattended:= RunInteractiveInstalls=="0"
}
If (!Unattended && !A_IsAdmin) {
    ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
    Run *RunAs %ScriptRunCommand%,,UseErrorLevel  ; Requires v1.0.92.01+
    ExitApp
}

AllowedChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_@#$&*()[]{};'\:|,./?"

passwd=
Loop 14
{
    Random charNo, 1, % StrLen(AllowedChars)
    passwd .= SubStr(AllowedChars,charNo,1)
}

Try {
    passwdNo := WriteAndShowPassword(passwd, path_to_password_file := -1)
} Catch e {
;    If (e.What!="RecordPassword")
;        MsgBox % "Exception " ObjectToText(e)
;    ExitApp
}
RegRead Hostname, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters, Hostname
RunWait %comspec% /C ""%A_ScriptDir%\CreateSharedAccount.cmd" "user %Hostname%" "Пользователь компьютера %Hostname% без авторизации" "" "%path_to_password_file%""
If (passwdNo)
    Exit
ExitApp

#include %A_ScriptDir%\..\GUI\Input Numbered Passwd.ahk
#include %A_ScriptDir%\..\Lib\ObjectToText.ahk
