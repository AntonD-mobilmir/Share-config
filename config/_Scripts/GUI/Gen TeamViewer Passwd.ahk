;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

AllowedChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_ !@#$%^&*()[]{};'\:|,./<>?"

passwd=
Loop 20
{
    Random charNo, 1, % StrLen(AllowedChars)
    passwd .= SubStr(AllowedChars,charNo,1)
}

passwordID := WriteAndShowPassword(passwd)

Run % "https://docs.google.com/forms/d/1Wy8ZFhfnV1VGYN_vHabQvr6Ziy9E9GTbgaua64CcORU/viewform?entry.287789183=" . URIEncode(passwordID)
Run https://docs.google.com/spreadsheets/d/179XOMsXbLEOoGIaN6_4gE43RVJ8fyQ57dw1DLe6XnF8/preview#gid=913963513

Exit

#include %A_ScriptDir%\Input Numbered Passwd.ahk
