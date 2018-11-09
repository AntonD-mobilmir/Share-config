;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
FileEncoding UTF-8
If (!A_IsAdmin) {
    Run % "*RunAs " DllCall( "GetCommandLine", "Str" ),,UseErrorLevel  ; Requires v1.0.92.01+
    ExitApp
}

uninstallList = %A_ScriptDir%\Known Uninstalls.tsv
EnvGet SystemRoot, SystemRoot

CheckFileTimeChanged(uninstallList)
Try {
    uninstList := ReadTSV(uninstallList, ["Quiet Uninstall String", "Uninstall String", "Registry Key", "Display Name"])
} Catch e {
    Throw Exception(ObjectToText(e))
}

regViews := [32]
If (A_Is64bitOS)
    regViews.Push(64)

uninstCount := uninstList.Length()
fhLog := FileOpen(A_Desktop "\" A_ScriptName "." A_Now ".txt", "a")
Progress A M R0-%uninstCount%, `n`n`n, Uninstalling…
For i, uninstStrArr in uninstList {
    If (!uninstStrArr[3])
        continue
    
    keyFound := 0
    For i, rv in regViews {
        Loop Reg, % uninstStrArr[3]
            keyFound := 1, break
    } Until keyFound
    
    If (!keyFound)
        continue
    uninstName := uninstStrArr[4]
    ;showDetails := InStr(uninstName, "Cyberlink") || InStr(uninstName, "YouCam")
    uninstStrArr.Delete(3,4)
    Progress,, % uninstName
    
    For j, uninstStr in uninstStrArr {
        If (!uninstStr)
            continue
        
        uninstArgs := ParseCommandLine(uninstStr, A_Tab A_Space ",") ; comma for RunDll32
        uninstApp := Trim(uninstArgs[0], """")
        SplitPath uninstApp, uninstAppFileName, uninstAppDir
        
        If (uninstAppFileName = "MsiExec.exe") {
            ;uninstall string for some programs looks like «MsiExec.exe /I{84D8451D-2ED6-3A59-ABA5-2A447F7C6310}»
            If (RegexMatch(uninstStr, "(.*MsiExec.exe""?\s)/I(.+)", m))
                uninstStr := m1 "/X" m2
            uninstStr .= " /passive /norestart"
        } Else If (uninstAppFileName = "RunDll32.EXE") {
            If (!FileExist(Trim(uninstArgs[1], """")))
                continue
        }
        ; Else If (!FileExist(uninstApp))
        ;    continue
        Try RunWait %uninstStr%, %uninstAppDir%, UseErrorLevel
        errLvl := ErrorLevel
        errTxt := errLvl ? (errLvl == "ERROR" ? " → Executable not found" : " → Error " errLvl) : " – OK"
        fhLog.WriteLine((errLvl ? "[!]" : "[.]") " " uninstName ": " uninstStr . errTxt)
        If (!errLvl)
            break
    }
    Progress %A_Index%
}
fhLog.Close()

ExitApp

CheckFileTimeChanged(ByRef path) {
    static files := {}
    FileGetTime ftime, %path%
    pathHash := L128Hash(path)
    
    If (files.HasKey(pathHash))
	r := (ftime == files[pathHash])
    Else
	r := ""
    files[pathHash] := ftime
    return r
}

; hash functions by Laszlo
; taken from https://autohotkey.com/board/topic/14040-fast-64-and-128-bit-hash-functions/ and modified for AHK_L
;MsgBox % L64Hash("12345678")
;MsgBox % L128Hash("12345678")
L64Hash(x) {						; 64-bit generalized LFSR hash of string x
   ;Local i, R = 0
   R := 0
   LHASH := LHashInit()					  ; 1st time set LHASH0..LHAS256 global table
   Loop Parse, x
   {
	  i := (R >> 56) & 255
	  R := (R << 8) + Asc(A_LoopField) ^ LHASH[i]
   }
   Return Hex8(R>>32) . Hex8(R)
}

L128Hash(x) {					   ; 128-bit generalized LFSR hash of string x
   ;Local i, S = 0, R = -1
   S := 0, R := -1
   LHASH := LHashInit()					  ; 1st time set LHASH0..LHAS256 global table
   Loop Parse, x
   {
	  i := (R >> 56) & 255
	  R := (R << 8) + Asc(A_LoopField) ^ LHASH[i]
	  i := (S >> 56) & 255
	  S := (S << 8) + Asc(A_LoopField) - LHASH[i]
   }
   Return Hex8(R>>32) . Hex8(R) . Hex8(S>>32) . Hex8(S)
}

Hex8(i) {						   ; integer -> LS 8 hex digits
    return Format("{:08X}", i & 0xFFFFFFFF)
;   SetFormat Integer, Hex
;   i:= 0x100000000 | i & 0xFFFFFFFF ; mask LS word, set bit32 for leading 0's --> hex
;   SetFormat Integer, D
;   Return SubStr(i,-7)			  ; 8 LS digits = 32 unsigned bits
}

LHashInit() {					   ; build pseudorandom substitution table
    static LHASH := ""
    If (LHASH=="") {
	;local i, u := 0, v := 0
	u := 0, v := 0
	LHASH := {}
	Loop 256 {
	    TEA(u,v, 1,22,333,4444, 8) ; <- to be portable, no Random()
	    LHASH[A_Index - 1] := (u<<32) | v
	}
    }
    return LHASH
}
									; [y,z] = 64-bit I/0 block, [k0,k1,k2,k3] = 128-bit key
TEA(ByRef y,ByRef z, k0,k1,k2,k3, n = 32) { ; n = #Rounds
   s := 0, d := 0x9E3779B9
   Loop %n% {					   ; standard = 32, 8 for speed
	  k := "k" . s & 3			  ; indexing the key
	  y := 0xFFFFFFFF & (y + ((z << 4 ^ z >> 5) + z  ^  s + %k%))
	  s := 0xFFFFFFFF & (s + d)	 ; simulate 32 bit operations
	  k := "k" . s >> 11 & 3
	  z := 0xFFFFFFFF & (z + ((y << 4 ^ y >> 5) + y  ^  s + %k%))
   }
}

ObjectToText(obj) {
    out := ""
    For i,v in obj
	out .= i ": " ( IsObject(v) ? "(" ObjectToText(v) ")" : (InStr(v, ",") ? """" v """" : v) ) ", "
    return SubStr(out, 1, -2)
}

StartsWith(ByRef long, ByRef short) {
    return short = SubStr(long, 1, StrLen(short))
}

#include %A_LineFile%\..\..\Lib\ReadCSV.ahk
#include %A_LineFile%\..\..\Lib\ParseCommandLine.ahk
