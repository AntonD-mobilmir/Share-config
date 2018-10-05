;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/>.
#NoEnv

; compare versions by components
VersionAtLeast(verTest, verMin) {
    For i, min in verMin {
        test := verTest[i]
        If (test < min)
            return false
        Else If (test > min)
            return true
    }
    
    ;equal
    return true
}
