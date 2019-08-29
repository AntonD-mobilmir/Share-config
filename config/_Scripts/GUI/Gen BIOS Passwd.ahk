;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

AllowedChars := "abcdefghijklmnopqrstuvwxyz0123456789"

passwd=
Loop 6
{
    Random charNo, 1, % StrLen(AllowedChars)
    passwd .= SubStr(AllowedChars,charNo,1)
}

passwordID := WriteAndShowPassword(passwd)

Run % "https://docs.google.com/forms/d/1-cxDunK4pEQDGD3NNC5jx2QygXUV9tO7YD-x6gvboyE/viewform?entry.1712958395&entry.992887697&entry.1317910798&entry.2009533208=" . UriEncode(passwordID)

Exit 

#include %A_ScriptDir%\Input Numbered Passwd.ahk
