;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

;test:
csvreport = "test 123"`,"test`n 1 2 3"`,123`,"q"`n4 5 6`, "456"`, 78.0`n""
MsgBox % ObjectToText(ParseCSV(csvreport))
csvreport = "test 123"`,"test`n 1 2 3"`,123`,"q"`n4 5 6`, "456"`, 78.0`n"
MsgBox % ObjectToText(ParseCSV(csvreport))
csvreport = "test 123"`,"test`n 1 2 3"`,123`,"q"`n4 5 6`, "456"`, 78.0`n"`n"
MsgBox % ObjectToText(ParseCSV(csvreport))

ParseCSV(ByRef csv) {
    data := [], datarow := [], datalen := StrLen(csv), lastFieldEnd := 0, curPos := 0, inQuote := 0
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
        
        If (sep!="`n" || (curPos - lastFieldEnd > 1))
            datarow.Push(CSV_unQuote(SubStr(csv, lastFieldEnd+1, curPos - lastFieldEnd - 1))), lastFieldEnd := curPos
        
        If (sep=="`n")
            data.Push(datarow), datarow := []
    }
    return data
}

CSV_unQuote(ByRef field) {
    If (StrLen(field) > 1 && StartsWith(field, """") && EndsWith(field, """")) ; if quoted, remove outside quotes and replace "" inside with "
        return StrReplace(SubStr(field, 2, -1), """""", """")
    Else
        return field
}

#include %A_LineFile%\..\StartsWith.ahk
#include %A_LineFile%\..\EndsWith.ahk
