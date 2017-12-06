;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

Read7zHashOut(path, ByRef colTitles := "", ByRef colStarts := "", ByRef colWidths := "") {
    global silent, debug
    ;7-Zip 17.01 beta (x64) : Copyright (c) 1999-2017 Igor  Pavlov : 2017-08-28
    ;
    ;Scanning
    ;1 file, 16228412167 bytes (16 GiB)
    ;
    ;CRC32    CRC64            SHA256                                                           SHA1                                     BLAKE2sp                                                                  Size  Name
    ;-------- ---------------- ---------------------------------------------------------------- ---------------------------------------- ---------------------------------------------------------------- -------------  ------------
    ;DD848BC2 9BA030906B28C2B1 6B216366D4E6F7DC61BF0F1FF7DF943CC5F10BF64B74CD2CB1D485F91E14CBE8 C1181E822B0A2F950235BFB732A2AAF4D3299D85 EACB9DF852BD7E0F976F2293695F957F1BB06BBD63BD1A5BD6EDEF6C5F9EFDB1   16228412167  Asus X541UJ-GQ526T Full HDD from factory.adi
    ;-------- ---------------- ---------------------------------------------------------------- ---------------------------------------- ---------------------------------------------------------------- -------------  ------------
    ;DD848BC2 9BA030906B28C2B1 6B216366D4E6F7DC61BF0F1FF7DF943CC5F10BF64B74CD2CB1D485F91E14CBE8 C1181E822B0A2F950235BFB732A2AAF4D3299D85 EACB9DF852BD7E0F976F2293695F957F1BB06BBD63BD1A5BD6EDEF6C5F9EFDB1   16228412167  
    ;
    ;Size: 16228412167
    ;
    ;CRC32  for data:              DD848BC2
    ;
    ;CRC64  for data:              9BA030906B28C2B1
    ;
    ;SHA256 for data:              6B216366D4E6F7DC61BF0F1FF7DF943CC5F10BF64B74CD2CB1D485F91E14CBE8
    ;
    ;SHA1   for data:              C1181E822B0A2F950235BFB732A2AAF4D3299D85
    ;
    ;BLAKE2sp for data:              EACB9DF852BD7E0F976F2293695F957F1BB06BBD63BD1A5BD6EDEF6C5F9EFDB1
    ;
    ;Everything is Ok
    data := []
    datai := 1
    Loop Read, %path%
    {
	If (!listHeadersLine) {
	    If (RegexMatch(A_LoopReadLine ,"\s+Size\s+Name\s*$"))
		listHeadersLine := A_LoopReadLine
	    ; skip everything else until headers
	} Else If (SubStr(A_LoopReadLine, 1, 3) == "---") {
	    If (!IsObject(colStarts)) { ; first horizontal line
		CalcColumnPositions(A_LoopReadLine, listHeadersLine, colTitles, colStarts, colWidths)
	    } Else ; second horizontal line
		break ; ignore totals
	} Else {
	    If (!IsObject(colStarts)) {
		CalcColumnPositions(listHeadersLine, listHeadersLine, colTitles, colStarts, colWidths)
		If (!silent)
		    MsgBox Warning: hash list didn't include horizontal line
	    }
	    If (!IsObject(colData)) {
		colData := []
	    row := []
	    For i,currCol in colStarts
		If (colWidths[i])
		    row[i] := Trim(SubStr(A_LoopReadLine, currCol, colWidths[i]))
		Else
		    row[i] := Trim(SubStr(A_LoopReadLine, currCol))
	    }
	    data[datai++] := row
	}
    }
    return data
}

CalcColumnPositions(ByRef txtLine, ByRef listHeadersLine, ByRef colTitles, ByRef colStarts, ByRef colWidths) {
    colStarts := []
    colWidths := []
    colTitles := []
    currCol := delimWidth := 1
    i:=1
    Loop Parse, txtLine, %A_Space%
    {
	If (w := StrLen(A_LoopField)) {
	    colStarts[i] := lastCol := currCol
	    currCol += StrLen(A_LoopField) + delimWidth
	    colTitles[i] := Trim(SubStr(listHeadersLine, lastCol, colWidths[i] := currCol - lastCol))
	    i++
	    delimWidth := 1
	} Else
	    delimWidth++
    }
    ; Filename is actually wider than ------------ beneath
    colWidths.Pop()
    return colStarts
}
