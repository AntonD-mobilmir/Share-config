;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

StripNonfilenameChars(ByRef c) {
    n := ""
    ;https://stackoverflow.com/a/31976060
    Loop Parse, c,,<>:"/\|?*
	If (Asc(A_LoopField) > 31)
	    n .= A_LoopField
    return n
}
