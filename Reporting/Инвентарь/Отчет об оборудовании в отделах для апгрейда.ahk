;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.
#NoEnv
;FileEncoding UTF-8 - actually CSV reports are in ANSI

EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemRoot,SystemRoot

pathReport = %A_Temp%\%A_ScriptName%.%A_Now%.tsv

exe7z := find7zexe()
tmp = %A_Temp%\%A_ScriptName%.%A_Now%

depts := {}, dc:=0
Progress A M,,Загрузка списка отделов
Loop Read, список отделов для апгрейда.txt
    If (RegexMatch(A_LoopReadLine, "(\S+)(?:@(\s|$))", em))
        depts[em1] := A_LoopReadLine, dc++
Progress Off

ofReport := FileOpen(pathReport, "a")
Progress A M R0-%dc%,%A_Space%,Чтение отчётов
reportTitle = dept%A_Tab%hostname%A_Tab%ram%A_Tab%hdd1size%A_Tab%hdd1name%A_Tab%hdd1sn%A_Tab%hdd1pn%A_Tab%hdd2size%A_Tab%hdd2name%A_Tab%hdd2sn%A_Tab%hdd2pn
ofReport.WriteLine(reportTitle)
For emailid, deptname in depts {
    Progress %A_Index%, %emailid%
    Loop Files, \\Srv1S-B.office0.mobilmir\Users\Public\Shares\profiles$\Share\Inventory\actual\RetailDepts\%emailid%\%emailid%-? *.7z
    {
        FileRemoveDir %tmp%
        RunWait %exe7z% x -o"%tmp%" -- "%A_LoopFileFullPath%" "Full WinAudit *.csv",, Hide UseErrorLevel
        
        nameLatest := "", timeLatest := 0
        Loop Files, %tmp%\Full WinAudit *.csv
            If (A_LoopFileTimeModified > timeLatest)
                timeLatest := A_LoopFileTimeModified, nameLatest := A_LoopFileName
        If (nameLatest) {
            Progress,,%emailid%: %nameLatest%
            RegexMatch(nameLatest, "Full WinAudit (\S+)", m)
            FileRead csvreport, %tmp%\%nameLatest% ; *P000
            rptdata := FilterCSVByFirstCol(csvreport, {3600: {3: 1}, 3700: {4: 1, 7: 2, 8: 3, 9: 4}}) ; , 3800: {3: 1, 6: 2, 8: 3, 9: 4}
            FileRemoveDir %tmp%, 1
            If (rptdata) {
                reportLine := ""
                For i, objRptLine in rptdata
                    If (objRptLine[""]!=3700 || objRptLine[1]!="0MB")
                        For j, field in objRptLine
                            If (j)
                                reportLine .= A_Tab ObjectToText(field)
                ofReport.WriteLine(deptname A_Tab m1 reportLine)
            }
        }
    }
}
ofReport.Close()
Progress Off
Run %pathReport%
ExitApp

FilterCSVByFirstCol(ByRef csv, ByRef filter) {
    data := [], datarow := [], datalen := StrLen(csv), lastFieldEnd := 0, curPos := 0, inQuote := 0, col := 1, row := 1
    Loop Parse, csv, `,"`n
    {
        curPos += StrLen(A_LoopField) + 1, sep := SubStr(csv, curPos, 1)
        If (curPos <= datalen) {
            If (sep=="""") {
                inQuote := !inQuote
                continue
            }
            If (inQuote)
                continue
        } Else
            sep := "`n"
        ; otherwise it's end of field
        
        If (sep!="`n" || (curPos - lastFieldEnd > 1)) {
            field := CSV_unQuote(SubStr(csv, lastFieldEnd+1, curPos - lastFieldEnd - 1)), lastFieldEnd := curPos, lastFieldEnd := curPos
            
            If (col) {
                If (col==1) {
                    If (col := filter.HasKey(field) ? 2 : 0)
                        datarow[""] := field, usecols := filter[field]
                } Else {
                    ;MsgBox % "col: " col "`nusecols: " ObjectToText(usecols) "`nfield: " field "`nusecols.HasKey(col)" usecols.HasKey(col)
                    If (usecols.HasKey(col))
                        datarow[usecols[col]] := field
                    col++
                }
            }
        }
        If (sep=="`n") {
            ;MsgBox % "col: " col "`nusecols: " ObjectToText(usecols) "`ndatarow: " ObjectToText(datarow)
            If (col > 1)
                If (!data.HasKey())
                data.Push(datarow), datarow := []
            col:=1, row++
        }
    }
    return data
}

CSV_unQuote(ByRef field) {
    If (StrLen(field) > 1 && StartsWith(field, """") && EndsWith(field, """")) ; if quoted, remove outside quotes and replace "" inside with "
        return StrReplace(SubStr(field, 2, -1), """""", """")
    Else
        return field
}

;Full WinAudit %hostname% *.csv

;"3600","Память","4096MB","1232MB","5916MB","2617MB"
;"3700","Жесткие диски","1","953867MB","Fixed hard disk media","","TOSHIBA DT01ACA100","X5GKA9PFS","MS2OA750","Primary","Master","121601","255","63","47304KB","Да","Да","OK"


;"3600","Память","8192MB","4467MB","10002MB","6422MB"
;"3700","Жесткие диски","1","122103MB","Fixed hard disk media","","ADATA SU800","2I3920037656","R0427ANR","Primary","Master","15566","255","63","","Да","Да","OK"
;"3700","Жесткие диски","2","476937MB","Fixed hard disk media","","TOSHIBA DT01ACA050","Y7E3KTRAS","MS1OA750","Primary","Master","60801","255","63","47304KB","Да","Да","OK"
;"3800","Логические диски","C","Fixed Drive","31%","19.1GB","44.3GB","63.4GB","System","NTFS","9A77-AFDB","8","512","11609649","16619775"
;"3800","Логические диски","D","Fixed Drive","17%","38.0GB","193.1GB","231.0GB","Data","NTFS","E81F-E332","8","512","50619520","60568319"
;"3800","Логические диски","R","Fixed Drive","5%","11.3GB","221.3GB","232.7GB","Backup","NTFS","962A-F6C7","8","512","58025461","60999679"
