;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

If (A_ScriptFullPath == A_LineFile) { ; this is direct call, not inclusion
    encoding = UTF-8
    outtxt = *
    outjson =
    
    actn := 0
    Loop %0%
    {
	argv := %A_Index%
	If (actn) {
	    If (actn="json")
		outjson := argv
	    If (actn="encoding")
		FileEncoding %argv%
	    Else If (actn="file")
		outtxt := Trim(actn)
	    actn=
	} Else {
	    If (argv == "/append") ; arguments without additional parameter
		append := 1
	    Else If (SubStr(argv,1,1) == "/") ; all arguments with additional parameter are above in «If (actn)» block
		actn := SubStr(argv, 2)
	    Else
		outtxt := argv
	}
    }
    
    fpo := GetFingerprint(textfp)
    
    If (outtxt)
	GetFingerprintTransactWriteout(textfp, outtxt, encoding, append)
    
    If (outjson)
	GetFingerprintTransactWriteout(JSON.Dump(fpo), outjson)
    ExitApp
}
; needed for above
#include %A_LineFile%\..\Lib\JSON.ahk

#include %A_LineFile%\..\Lib\GetFingerprint.ahk
