;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

InvReportsToSpreadsheet(ByRef pathReport, ByRef pathInv7zBase, ByRef depts, ByRef sep := "", ByRef q := """") {
    ;pathReport = %A_Temp%\%A_ScriptName%.%A_Now%.tsv
    ;pathInv7zBase = \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Inventory\actual\RetailDepts
    ;depts := {"ab": "Абрикос", "el": "Электроника"}
    
    ;dc := 0
    ;For i in depts
    ;    dc++
    dc := depts.GetCapacity()
    
    If (!sep) {
        ;SplitPath pathReport, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        SplitPath pathReport, , , OutExtension
        sep := OutExtension=="tsv" ? A_Tab : ","
    }
    
    ofReport := FileOpen(pathReport, "a", "UTF-8")
    Progress A M R0-%dc%,`n`n,Чтение отчётов
    ofReport.WriteLine(q "dept" q sep q "dir\hostname" q sep q "trello card" q sep WinAuditCSVToSheetRow_GetColNamesLine(sep, q))
    For emailid, deptname in depts {
        Progress %A_Index%, %emailid%
        nameVariants := [emailid "\" emailid]
        If (InStr(emailid, "."))
            id2 := StrReplace(emailid, "."), nameVariants.Push(id2 "\" emailid, emailid "\" id2, id2 "\" id2)
        For i, nameVariant in nameVariants
            For j, nameSuffix in ["K", "2", "3"]
                Loop Files, %pathInv7zBase%\%nameVariant%-%nameSuffix% *.7z
                    reportrow := InventoryReport7zToSheetRow(A_LoopFileFullPath, emailid, sep, q, trelloid), ofReport.WriteLine(q deptname q sep q nameVariant "-" nameSuffix q sep q CutTrelloCardURL(trelloid) q sep reportrow)
    }
    ofReport.Close()
    Progress Off
}

#include %A_LineFile%\..\WinAuditCSVToSheetRow.ahk
#include %A_LineFile%\..\CutTrelloCardURL.ahk
