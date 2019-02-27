;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	If (RegExMatch(A_LoopReadLine, "ASi)[\s()]*SET\s+(?P<Name>.+)\s*=(?P<Value>.+)", m)) {
	    If (Trim(Trim(mName), """") = varname) {
		return Trim(Trim(mValue), """")
	    }
	}
    }
    Throw Exception("Var not found",, varname)
}
