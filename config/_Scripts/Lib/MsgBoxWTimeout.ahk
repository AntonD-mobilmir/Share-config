;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

MsgBoxWTimeout(text, timeoutName, p := "") {
    ; p is an object with following optional attributes:
    ; title
    ; options := 0x35
    ; timeout := 5
    ; timeoutUnit := "Minutes"
    ; IfMsgBox := {Timeout: 0, Yes: 1, …} strings-to-values mapping
    
    If (!IsObject(p))
        p := {}
    rvMap := p.IfMsgBox ? p.IfMsgBox : {Timeout: -1, Yes: 1, Retry: 1, Continue: 2, TryAgain: 1, Abort: 0, Ignore: -1, Cancel: 0, No: 0}
    
    If (p.timeout)
        timeout := p.timeout, timeoutUnit := p.timeoutUnit ? p.timeoutUnit : "Minutes"
    Else
        timeout := 5, timeoutUnit := "Minutes"
    timeoutMsgText := FormatTimeSoon(timeout, timeoutUnit)
    timeout_s := timeout * {Seconds: 1, Minutes: 60, Hours: 60*60, Days: 24*60*60}[timeoutUnit]
    MsgBox % p.options ? p.options : 0x35, % p.title, %text%`n[%timeoutName%%timeoutMsgText%], %timeout_s%
    IfMsgBox Yes
        return rvMap.Yes
    IfMsgBox No
        return rvMap.No
    IfMsgBox OK
        return rvMap.OK
    IfMsgBox Cancel
        return rvMap.Cancel
    IfMsgBox Abort
        return rvMap.Abort
    IfMsgBox Ignore
        return rvMap.Ignore
    IfMsgBox Retry
        return rvMap.Retry
    IfMsgBox Continue ; [v1.0.44.08+]
        return rvMap.Continue ; [v1.0.44.08+]
    IfMsgBox TryAgain ; [v1.0.44.08+]
        return rvMap.TryAgain ; [v1.0.44.08+]
    IfMsgBox Timeout ; (that is, the word "timeout" is present if the MsgBox timed out)
        return rvMap.Timeout ; (that is, the word "timeout" is present if the MsgBox timed out)
}

#include %A_LineFile%\..\FormatTimeSoon.ahk
