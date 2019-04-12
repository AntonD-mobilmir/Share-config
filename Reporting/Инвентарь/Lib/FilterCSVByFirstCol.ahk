;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

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
