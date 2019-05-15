;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

RegKeyCopy(ByRef src, ByRef dst) {
    errors := 0
    If (!RegexMatch(src, "A)(?P<ComputerName>\\\\[^:\/]+:)?(?P<RootKey>[^\/:]+?)\\(?P<SubKey>.+)", srcReg))
        Throw Exception("reg root key not found in src",, src)
    
    ;MsgBox src: %src%`nsrcRegRootKey: %srcRegRootKey%`nsrcRegSubKey: %srcRegSubKey%
    srcSubkeyLen := StrLen(srcRegSubKey) + 1
    
    Loop Reg, %src%, R
    {
        If (srcRegSubKey == SubStr(A_LoopRegSubKey, 1, StrLen(srcRegSubKey)))
            dstRegSubkey := dst . SubStr(A_LoopRegSubKey, srcSubkeyLen)
        Else
            Throw Exception("Loop Reg subkey does not start with Src subkey",, A_LoopRegSubKey " ← " srcRegSubKey)
        RegRead v
        RegWrite %A_LoopRegType%, %dstRegSubkey%, %A_LoopRegName%, %v%
        errors += ErrorLevel
    }
    ErrorLevel := errors
}
