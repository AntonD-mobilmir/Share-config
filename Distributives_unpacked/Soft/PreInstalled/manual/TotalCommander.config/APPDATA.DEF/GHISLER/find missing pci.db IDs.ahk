;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding CP0
log = %A_ScriptFullPath%.log
FileMove %log%, %log%.bak, 1

lineIDs := {}
splitIDs := {}

Loop Read, pci.db
{
    If (!IsObject(m := ParseLine(A_LoopReadLine)))
	Throw Exception("Error parsing line",, m " in pci.db (" A_Index "):" A_LoopReadLine)
    lineIDs[m.FmtID] := m.Name
    
    ; в некоторых строках pci.db от RedDetect вместо DevID написано NULL. Такие надо будет найти.
    ;ToDo: эта часть не работает :(
    If (!splitIDs.HasKey(m.1))
	splitIDs[m.1] := {}
    splitIDs[m.1][m.3 . m.4] := ""
}

missObj := {}
missing =
Loop Read, pci.db.bak
{
    If (!(A_LoopReadLine && IsObject(m := ParseLine(A_LoopReadLine)))) {
	FileAppend %m% in pci.db.bak (%A_Index%)`, skipped: «%A_LoopReadLine%»`n, %log%
	continue
    }
    ;10ec|0269|NULL|NULL
    If (!(lineIDs.HasKey(m.FmtID) || (m.2 == "NULL" && splitIDs[m.1].HasKey(m.3 . m.4)))) {
	missObj[m.FmtID] := m.Name
	missing .= m.FmtID "|" m.Name "`n"
    }
}

If (missing) {
    If (FileExist("pci.missing-ids.db")) {
	FileGetTime tmbakf, pci.missing-ids.db
	FileMove pci.missing-ids.db, pci.missing-ids.%tmbakf%.db
	If (ErrorLevel)
	    Throw Exception("Move error",, A_LastError)
    }
    FileAppend % missing, pci.missing-ids.db
    ;MsgBox %missing%
}
ExitApp
    
ParseLine(ByRef line) {
    static rhi := "(NULL|[^|]{0,4})" ; Regex for Hex ID
    If (!RegexMatch(line, "SO)^" rhi  "\|" rhi "\|" rhi "\|" rhi "\|(?P<Name>.*)", m))
	return "Regex mismatch"
    o := {}
    o.Name := m.Name
    Loop 4
    {
	q := Trim(m.Value(A_Index), "x")
	o[A_Index] := q
	If (q=="" || q = "NULL") {
	    FmtID .= "NULL|"
	} Else {
	    str := Format("{:04ls}", q)
	    hex := Format("{:04x}", "0x" q)
	    If (str != hex)
		return "Bad ID """ str """"
	    FmtID .= hex "|"
	}
    }
    o.FmtID := Trim(FmtID, "|")
    ;MsgBox % m.1 "|" m.2 "|" m.3 "|" m.4 " → " o.FmtID
    return o
}
