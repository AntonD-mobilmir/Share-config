;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

CutTrelloCardURL(ByRef url, mode := 0) {
    static Modes := { 0: [1, 4]
                    , 1: [3]
                    , 2: [2] }
    out := ""
    If (!Modes.HasKey(mode))
        mode := 0
    ;                     1  2   3                 4
    If (RegexMatch(url, "S)^(.*(/c/([^/]+)/\d+))[^#]*(#.+)?", shn)) {
        For i, cutPart in Modes[mode]
            out .= shn%cutPart%
        return out
    }
}
