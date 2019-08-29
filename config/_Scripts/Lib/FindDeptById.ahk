;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

If (A_LineFile==A_ScriptFullPath) {
    FileAppend % deptName := FindDeptById(A_Args[1], line) "`n", *, CP1
    Loop 4
        FileAppend % line[A_Index] "`n", *, CP1
    ExitApp
}

FindDeptById(mailUserId, ByRef line := "") {
    FileReadLine deptsListURL, %A_LineFile%\..\..\pseudo-secrets\FindDeptBymailUserId.ahk.txt, 1
    deptsList := GetURL(deptsListURL)
    
    If (deptsList) {
        Loop Parse, deptsList, `n, `r
        {
            ;dept-name email-ID@	mailUserId	email	alias...
            line := StrSplit(A_LoopField, "`t",,4)
            If (line[2]=mailUserId && RegexMatch(line[1], "A)(?P<Name>.+) (?P<ID>[^ ]+)@", dept)) { ; deptName, deptID are assigned here
                line["deptID"] := deptID
                atPos := InStr(line[3], "@")
                line["mailUserId"] := SubStr(line[3], 1, atPos-1)
                line["mailDomain"] := SubStr(line[3], atPos+1)
                return deptName
            }
        }
    }
}

#include %A_LineFile%\..\GetURL.ahk
