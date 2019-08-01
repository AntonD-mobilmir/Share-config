;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

length := A_Args[1]
If (!length)
    length := 14
AllowedChars := A_Args[2]
If (!AllowedChars)
    AllowedChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_ @#$&*()[]{};'\:|,./<>?~``"

fout := FileOpen("*", "w", CP1)
Loop %length%
{
    Random charNo, 1, % StrLen(AllowedChars)
    FileAppend % SubStr(AllowedChars,charNo,1), *, CP1
}

FileAppend %passwd%`n, *, CP1
