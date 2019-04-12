;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

InventoryReport7zToSheetRow(ByRef path7zreport, ByRef progessNamePrefix := "", ByRef separator := ",", ByRef quote := """", ByRef trelloid := 0) {
    static exe7z, tmp
    If (!exe7z)
        exe7z := find7zexe()
    If (!tmp)
        tmp = %A_Temp%\%A_ScriptName%.%A_Now%

    FileRemoveDir %tmp%, 1
    Try {
        RunWait %exe7z% x -o"%tmp%" -- "%path7zreport%" "Full WinAudit *.csv" "* trello-id.txt",, Hide UseErrorLevel
        If (trelloid != 0) {
            Loop Files, %tmp%\* trello-id.txt
            {
                FileReadLine trelloid, %A_LoopFileFullPath%, 1
                break
            }
        }
        
        nameLatest := "", timeLatest := 0
        Loop Files, %tmp%\Full WinAudit *.csv
            If (A_LoopFileTimeModified > timeLatest)
                timeLatest := A_LoopFileTimeModified, nameLatest := A_LoopFileName
        If (nameLatest) {
            If (progessNamePrefix)
                Progress,,%progessNamePrefix%: %nameLatest%
            FileRead csvreport, %tmp%\%nameLatest% ; *P000
            return WinAuditCSVToSheetRow(csvreport, separator, quote)
        }
    } Finally {
        FileRemoveDir %tmp%, 1
    }
}

#include %A_LineFile%\..\WinAuditCSVToSheetRow.ahk
