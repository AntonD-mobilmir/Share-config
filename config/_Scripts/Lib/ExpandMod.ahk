;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <https://creativecommons.org/licenses/by-sa/4.0/legalcode.ru>.

ExpandMod(string, substVars) {
    PrevPctChr:=0
    LastPctChr:=0
    VarnameJustFound:=0
    output:=""
    
    While ( LastPctChr:=InStr(string, "%", true, LastPctChr+1) ) {
	If (VarnameJustFound) {
            vname := SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
            If (IsFunc(substVars)) {
                substVars.Call(vname)
            } Else {
                If (substVars.HasKey(vname)) {
                    currEnvVar := substVars[vname]
                } Else {
                    EnvGet currEnvVar,%vname%
                    If (!currEnvVar) {
                        Try {
                            currEnvVar := %vname%
                        } Catch {
                            currEnvVar := substVars[""]
                        }
                    }
                }
            }
	    output .= currEnvVar
	    VarnameJustFound:=0
	} else {
	    output .= SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    If (SubStr(string, LastPctChr+1, 1) == "%") { ;double-percent %% skipped ouside of varname
		output .= "%"
		LastPctChr++
	    } else {
		VarnameJustFound:=1
	    }
	}
	PrevPctChr:=LastPctChr
    }
    
    If VarnameJustFound ; That's bad, non-closed varname
	Throw Exception("Var name not closed")
    
    output .= SubStr(string,PrevPctChr+1)
    
    return % output
}
