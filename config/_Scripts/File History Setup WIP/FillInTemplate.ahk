;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
global GUID

TypeLib := ComObjCreate("Scriptlet.TypeLib")
NewGUID := TypeLib.Guid
TypeLib :=

If (!RegexMatch(NewGUID, "{([^}]+?)}", GUID)) {
    GUID := NewGUID
}
GUID := Format("{:Ls}", Trim(GUID, "{}"))

outFileName=%2%
If (!outFileName) {
    outFileName:="*"
} Else If (FileExist(outFileName)) {
    Throw "out file exist: " . outFileName
}

Try {
    Loop Read, %1%, %outFileName%
	FileAppend % Expand(A_LoopReadLine) . "`n"
} Catch e {
    Throw e
}

ExitApp

Expand(string) {
    PrevPctChr:=0
    LastPctChr:=0
    VarnameJustFound:=0
    output:=""

    While ( LastPctChr:=InStr(string, "%", true, LastPctChr+1) ) {
	If (VarnameJustFound) {
	    reqdVarName := SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    If (reqdVarName)
		If (%reqdVarName%)
		    CurrEnvVar:=%reqdVarName%
	    If (!CurrEnvVar)
		EnvGet CurrEnvVar,%reqdVarName%
	    output .= CurrEnvVar
	    CurrEnvVar=
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

    If (VarnameJustFound) ; That's bad, non-closed varname
	Throw Exception("Var name not closed")
	
    output .= SubStr(string,PrevPctChr+1)
    
    return % output
}
