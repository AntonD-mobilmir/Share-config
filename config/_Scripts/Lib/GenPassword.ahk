;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
FileEncoding UTF-8

If (A_LineFile == A_ScriptFullPath) {
    length := A_Args[1]
    If (!length)
        length := 14
    AllowedChars := A_Args[2]
    If (!AllowedChars)
        AllowedChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        ;AllowedChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_ @#$*[]{};'\:,./?~``"
    FileAppend % GenPassword(length, AllowedChars) "`n", *, CP1
    ExitApp
}

GenPassword(length := 20, ByRef AllowedChars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") {
    out := ""
    Loop %length%
    {
        Random charNo, 1, % StrLen(AllowedChars)
        out .= SubStr(AllowedChars,charNo,1), *, CP1
    }
    return out
}
