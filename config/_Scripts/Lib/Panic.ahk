;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.

Panic(except := "", msg := "", errCode := "") {
    If (errCode=="")
        errCode := A_LastError
    If (msg)
        errMsg := msg . ", код системной ошибки: " Format("0x{:X}", errCode) . (IsObject(except) ? ", исключение: " ObjectToText(except) : "")
    Else
        errMsg := ( IsObject(except) ? except.Extra . ", ошибка " except.What : "Ошибка в " A_ScriptName ) ", код системной ошибки: " errCode
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If (RunInteractiveInstalls!="0")
        MsgBox %errMsg%
    Else
        FileAppend %errMsg%`n, **, CP1
    ExitApp errCode ? errCode : 1
}

#include %A_LineFile%\..\ObjectToText.ahk
