﻿;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

FileEncoding UTF-16

tempRegFile=%A_Temp%\HKCU Shell Folders.%A_Now%.reg
Loop Read, %A_ScriptDir%\HKCU Shell Folders template.ini, *%tempRegFile%
{
    FileAppend % ExpandWithScreen(A_LoopReadLine) . "`r`n"
}

If (FileExist(A_Windir . "\SysNative")) {
    sysNative := A_Windir . "\SysNative"
} Else {
    sysNative := A_Windir . "\System32"
}

RunWait "%sysNative%\reg.exe" IMPORT "%A_ScriptDir%\HKCU User Shell Folders.reg"
RunWait "%sysNative%\reg.exe" IMPORT "%tempRegFile%"
FileDelete %tempRegFile%
ExitApp

;--
;Expand env vars in string, ignoring %% (double percent sequences)
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

ExpandWithScreen(string) {
    PrevPctChr:=0
    LastPctChr:=0
    VarnameJustFound:=0
    output:=""

    While ( LastPctChr:=InStr(string, "%", true, LastPctChr+1) ) {
	If VarnameJustFound
	{
	    EnvGet CurrEnvVar,% SubStr(string,PrevPctChr+1,LastPctChr-PrevPctChr-1)
	    output .= StrReplace(CurrEnvVar, "\", "\\")
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

    ;If VarnameJustFound ; That's bad, non-closed varname
    ;	Throw ("Var name not closed with %")
    
    output .= SubStr(string,PrevPctChr+1)
    
    return % output
}
