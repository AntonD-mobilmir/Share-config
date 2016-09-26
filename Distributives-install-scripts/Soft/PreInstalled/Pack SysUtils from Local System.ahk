#NoEnv

SetWorkingDir %A_ScriptDir%

RunWait %comspec% /C "%A_ScriptDir%\wget SysInternals.cmd"

tempArcDir=%A_Temp%\SysUtils-pack
x7zipLZMA2BCJ2Switches=-mx=9 -m0=BCJ2 -m1=LZMA2:a=2:fb=273 -m2=LZMA2:d22 -m3=LZMA2:d22 -mb0:1 -mb0s1:2 -mb0s2:3 -mqs

Loop doc\sysutils-lists\*.list
{
    ListsCount := A_Index
    
    List%A_Index% := A_LoopFileLongPath
    SplitPath A_LoopFileName, , , , ArcName%A_Index%
    FileCreateDir %tempArcDir%
    ArcName%A_Index% := tempArcDir . "\SysUtils_" . ArcName%A_Index% . ".7z"
}

UnlistedNumber := ListsCount+1
ArcName%UnlistedNumber% := tempArcDir . "\SysUtils_Unlisted.7z"

Loop %UnlistedNumber%
{
    CurrentlyIncludedList := A_Index
    
    If List%A_Index%
	InclExclCmdlArgs := " -i@""" . List%A_Index% . """"
    Else
	InclExclCmdlArgs=
    
    Loop %ListsCount%
    {
	If ( CurrentlyIncludedList != A_Index ) {
	    InclExclCmdlArgs .= " -x@""" . List%A_Index% . """"
	}
    }
    
    RunWait % """c:\Program Files\7-Zip\7zG.exe"" u " . x7zipLZMA2BCJ2Switches . InclExclCmdlArgs . " -- """ . ArcName%A_Index% . """", C:\SysUtils
;    MsgBox %InclExclCmdlArgs%
}

Loop Files, %tempArcDir%\*.7z
    CompareMoveDiff(A_LoopFileFullPath, "auto\SysUtils\" . A_LoopFileName) || CompareMoveDiff(A_LoopFileFullPath, "..\..\Soft com freeware\PreInstalled\manual\" . A_LoopFileName)
    
; not working: MsgBox Not found destination or error moving "%A_LoopFileFullPath%"

Run %comspec% /C ""%A_AppDataCommon%\mobilmir.ru\Common_Scripts\tc.cmd" "%tempArcDir%" "%A_ScriptDir%""

CompareMoveDiff(src,dest) {
    IfExist %dest%
    {
	FileGetSize sizeNewArc, %src%
	If (sizeNewArc <= 32) {
	    FileDelete %src%
	} Else {
	    RunWait C:\SysUtils\UnxUtils\cmp.exe -s "%src%" "%dest%",,Min UseErrorLevel
	    If (ErrorLevel==0) {
		FileDelete %src%
	    } Else If (ErrorLevel==1) {
		FileMove %src%,%dest%,1
		return !ErrorLevel
	    }
	}
    }
    
    return 0
}
