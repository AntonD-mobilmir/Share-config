;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

GetPseudoSecrets(lineNo := "") {
    static secretsPath := A_LineFile "\..\..\pseudo-secrets\" A_ScriptName ".txt"
         , data := "", fullDataRead := 0
    If (!fullDataRead) { ; reading
        If (!data)
            data := []
        If (lineNo) {
            If (!data.HasKey(lineNo))
                FileReadLine line, %secretsPath%, %lineNo%
        } Else {
            Loop Read, %A_LineFile%\..\..\pseudo-secrets\%A_ScriptName%.txt
                data[A_Index] := A_LoopReadLine
            fullDataRead := 1
        }
    }
    If (lineNo) ; returning
        return data[lineNo]
    Else
        return data
}
