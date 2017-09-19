;usage is similar to pathman.exe (https://www.microsoft.com/en-us/download/details.aspx?id=17657)
;        /as path[;path[;path ...]]
;                Adds the semicolon-separated paths to the system path.

;        /au path[;path[;path ...]]
;                Adds the semicolon-separated paths to the user path.

;        /rs path[;path[;path ...]]
;                Removes the semicolon-separated paths from the system path.

;        /ru path[;path[;path ...]]
;                Removes the semicolon-separated paths from the user path.

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8

mode := 0		; 0=add, 1=remove
hive := A_IsAdmin	; 0=user, 1=system
Loop %0%
{
    argv := %A_Index%
    sw := 0
    Loop Parse, argv
    {
	If (A_Index == 1) {
	    If (A_LoopField="/")
		sw := 1
	    Else
		break
	} Else If (A_LoopField = "a") {
	    mode := 0
	} Else If (A_LoopField = "r") {
	    mode := 1
	} Else If (A_LoopField = "u") {
	    hive := 0
	} Else If (A_LoopField = "s") {
	    hive := 1
	}
    }
    
    If (!sw) {
	If (hive)
	    key := "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment"
	Else
	    key := "HKEY_CURRENT_USER\Environment"
	
	errc += ModifyPaths(mode, argv, key)
    }
}

EnvUpdate
ExitApp errc != 0

ModifyPaths(ByRef mode, ByRef paths, ByRef key) {
    RegRead curPath, %key%, Path
    curPath := Trim(curPath, ";") ";"
    updated := false
    
    FileAppend key: %key%`ncurPath: %curPath%`npaths: %paths%`n,**, CP1
    Loop Parse, paths, `;
    {
	If (!A_LoopField)
	    continue
	tpath := Trim(A_LoopField, """`n`r`t ")
	FileAppend tpath: %tpath%`t,**,CP1
	If (!(foundPos := InStr(curPath, tpath ";")) == !mode) { ; not found(0) = add(0) AND found(1) = remove(1); !("not") us used to convert InStr pos to bool
	    FileAppend foundPos: %foundPos%,**,CP1
	    updated := true
	    If (mode)
		curPath := SubStr(curPath, 1, foundPos-1) . SubStr(curPath, foundPos + StrLen(tpath) + 2) ; magic "2" to avoid double ; (";;") in junction
	    Else
		curPath .= tpath ";"
	}
	FileAppend `n,**,CP1
    }
    FileAppend updated curPath: %curPath%`n,**,CP1
    
    If (updated) {
	RegWrite REG_EXPAND_SZ, %key%, Path, % RTrim(curPath, ";")
	return 0
    } Else {
	return 1
    }
}
