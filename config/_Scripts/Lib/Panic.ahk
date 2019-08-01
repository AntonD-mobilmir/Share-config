;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.

Panic(except := "", msg := "", errCode := "") {
    If (errCode=="")
        errCode := A_LastError
    If (msg)
        errMsg := msg . ", код системной ошибки: " Format("0x{:X}", errCode) . (IsObject(except) ? ", исключение: " ObjectToText(except) : "")
    Else
        errMsg := ( IsObject(except) ? except.Extra . ", ошибка " except.What : "Ошибка в " A_ScriptName ) ", код системной ошибки: " errCode
    EnvGet Unattended, Unattended
    If (!Unattended) {
        EnvGet RunInteractiveInstalls, RunInteractiveInstalls
        Unattended := RunInteractiveInstalls=="0"
    }
    FileAppend %errMsg%`n, **, CP1
    If (!Unattended)
        MsgBox %errMsg%
    ExitApp errCode ? errCode : 1
}

#include %A_LineFile%\..\ObjectToText.ahk
