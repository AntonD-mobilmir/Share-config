;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

ReplaceNonfilenameChars(ByRef c, ByRef filler := "") {
    n := ""
    ;https://stackoverflow.com/a/31976060
    Loop Parse, c,<>:"/\|?*
    {
        thisField := ""
        Loop Parse, A_LoopField
            thisField .= Asc(A_LoopField) > 31 ? A_LoopField : ""
        n .= (A_Index > 1 ? filler : "") thisField
    }
    return n
}
