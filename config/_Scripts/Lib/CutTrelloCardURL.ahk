;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

CutTrelloCardURL(ByRef url, mode := 0) {
    If (mode && RegexMatch(url, "^.*?/c/([^/]+)/\d+", shn))
	return shn1
    Else
	If (RegexMatch(url, "^.*?/c/[^/]+/\d+", shn))
	    return shn
}
