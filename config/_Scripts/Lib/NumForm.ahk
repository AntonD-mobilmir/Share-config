;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

NumForm(ByRef num, ByRef single, ByRef few, ByRef many) {
    lastDigit := SubStr(Floor(Num), 0)
    If (SubStr(Floor(Num), -1, 1)=="1" || lastDigit > 4)
	return many
    Else If (lastDigit==1)
	return single
    Else
	return few
}
