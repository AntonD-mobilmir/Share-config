;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

WildcardMatch(ByRef string, ByRef wildcard) {
    ;MsgBox % "string: " string "`nwildcard: " wildcard
    maskPos := InStr(wildcard, "*")
    If (maskPos) {
        If (SubStr(string, 1, maskPos-1) != SubStr(wildcard, 1, maskPos-1))
            return false
        nextMaskPos := InStr(wildcard, "*",, maskPos+1)
        If (nextMaskPos) {
            nextSubstr := SubStr(wildcard, maskPos+1, nextMaskPos-maskPos-1)
            nextSubstrPos := maskPos-1
            ;MsgBox % "nextSubstrPos: " nextSubstrPos "`nnextSubstr: " nextSubstr
            While nextSubstrPos := InStr(string, nextSubstr,, nextSubstrPos+1)
                If (WildcardMatch(SubStr(string, nextSubstrPos), SubStr(wildcard, nextMaskPos)))
                    return true
            return false
        } Else {
            tail := SubStr(wildcard, maskPos+1)
            return !tail || tail = SubStr(string, -StrLen(tail)+1)
        }
    } Else {
        return string = wildcard
    }
}
