;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv

ScreenUnsafeChars(str) {
    static unsafe := { """": """""" }
                     ;{ "`r": "", "`n": "", "`t": "" }
         , unsafeChars := ""
    If (unsafeChars=="")
        For c in unsafe
            unsafeChars .= c
    out := "", curPos := 0
    Loop Parse, str, %unsafeChars%
    {
        curPos += StrLen(A_LoopField) + 1
        unsChar := SubStr(str, curPos, 1)
        subst  := unsafe[unsChar]
        If (!subst)
            subst := "\" . unsChar
        
        out .= A_LoopField . subst
    }
    return """" SubStr(out, 1, -StrLen(subst)) """"
}
