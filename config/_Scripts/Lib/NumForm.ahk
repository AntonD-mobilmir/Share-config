;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

NumForm(ByRef num, ByRef single, ByRef few, ByRef many) {
    twoLastDigits := Mod(Floor(num), 100)
    lastDigit := Mod(twoLastDigits, 10)
    If ((twoLastDigits > 4 && twoLastDigits < 21) || !lastDigit || lastDigit > 4)
	return many
    Else If (lastDigit==1)
	return single
    Else
	return few
}

If (A_LineFile==A_ScriptFullPath) {
    Loop
    {
	testText := ""
	If (A_Index == 1) {
	    For i, v in [0,1,2,10,11,14,15,20,21,22,25,30,100,101,111]
		testText .= v " карточ" NumForm(v, "ка", "ки", "ек") "`n"
	} Else
	    Loop 10
	    {
		Random v, 1, 1000
		testText .= v " чис" NumForm(v, "ло", "ла", "ел") "`n"
	    }
	MsgBox % Trim(testText, "`n")
    }
}
