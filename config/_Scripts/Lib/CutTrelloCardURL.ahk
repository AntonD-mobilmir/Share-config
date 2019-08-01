;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

CutTrelloCardURL(ByRef url, mode := "") {
    static regexModes := ["^.*?/c/([^/]+)/\d+", "^.*?(/c/[^/]+/\d+)"]
    If mode is Integer
    {
        If (RegexMatch(url, regexModes[mode], shn))
            return shn1
    } Else If (RegexMatch(url, "^.*?/c/[^/]+/\d+", shn))
        return shn
}
