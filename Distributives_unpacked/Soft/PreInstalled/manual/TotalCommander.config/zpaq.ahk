;script invokes zpaq, intended to be run by totalcmd.exe
;after setting up in usercmd.ini

;command line: zpaq.ahk <cmd> <utf8 files list> <destination>
; <cmd>	: a,l or x
; <utf8 files list> : path to геа8 text file which contains newline-delimeted list files to be processed by zpaq
; <destination> : path to destination folder for a and x commands (in case of l, it is ignored)

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#SingleInstance off

FileEncoding UTF-16

Global Path,LocalAppData,SystemDrive
EnvGet Path,PATH
EnvGet LocalAppData,LOCALAPPDATA
EnvGet SystemDrive,SYSTEMDRIVE

zpaqexe := """" . Findzpaqexe() . """"
Try {
    teeexe := FindTeeExe()
    ; this way redirection works but records overlap : redirCmd = 2>&1 | "%teeexe%" -a
    redirCmd = | "%teeexe%" -a
    cmdSuffix = || PAUSE
} Catch {
    redirCmd := ">>"
    cmdSuffix := ""
}
cmd=%1%

If (cmd="l")
    tmpListFile=%A_Temp%\%A_ScriptName%-list.%A_Now%.txt

Loop Read, %2%
{
    SplitPath A_LoopReadLine, lastListedFileName, lastListedDir, OutExtension, lastListedNameNoExt, OutDrive
    If (cmd="x") {
	WaitCPUIdle (zpaqPID, 1, 30, 1)
	Run %comspec% /U /C "CHCP 65001 & %zpaqexe% x "%A_LoopReadLine%" -to "%3%%lastListedNameNoExt%" 2>>"%3%%lastListedNameNoExt%.errors.log" %redirCmd% "%3%%lastListedNameNoExt%.log" %cmdSuffix%",,Min, zpaqPID
    } Else If (cmd="l") {
	RunWait %comspec% /U /C "CHCP 65001 & %zpaqexe% l "%A_LoopReadLine%" 2>>&1 %redirCmd% "%tmpListFile%" %cmdSuffix%",,Min
    } Else If (cmd="a") {
	If (A_Index==1) {
	    files := Object()
	    curBasePath := lastListedDir
	} Else {
	    curBasePath := CommonPath(curBasePath, lastListedDir)
	}
	files.Push(A_LoopReadLine)
	If (!longPaths) {
	    ; even with START "" /D "\\?\%curBasePath%" and relative paths to source files (or *), zpaq it still cannot pack if full path length is 260 or more chars (despire relative path is shorter). If such paths found, let's try to use \\?\ prefixes.
	    If (SubStr(A_LoopReadLine, 0)=="\") {
		;Loop Files explicitly ignores files with paths longer than 259 chars, even with \\?\ -- Loop Files, %A_LoopReadLine%*, R
		tmpListName = %A_Temp%\%A_ScriptName%.%A_Now%.txt
		RunWait %comspec% /U /C "DIR /S /B "%A_LoopReadLine%*" >"%tmpListName%""
		Loop Read, %tmpListName%
		{
		    If (StrLen(A_LoopReadLine)>259) {
			longPaths:=1
			break
		    }
		}
		FileDelete %tmpListName%
	    } Else {
		longPaths:=StrLen(A_LoopReadLine)>259
	    }
	}
    } Else {
	MsgBox Command unsupported: %cmd%
    }
}

If (cmd="l") {
    Run "%tmpListFile%"
} Else If (cmd="a") {
    If (curBasePath) {
	SplitPath curBasePath, arcName
    } Else {
	arcName:=A_Now
    }
    
    If (!longPaths) {
        cutChars := StrLen(curBasePath) + 2
    }
    For i,v in files {
	If (longPaths) {
	    Loop Files, % RTrim(v, "\"), FD
	    {
		filesList .= """\\?\" . A_LoopFileLongPath . ( (SubStr(v,0) == "\") ? "\*" : "" ) . """ " 
	    }
	} Else {
	    filesList .= """" . SubStr(v, cutChars) . ( (SubStr(v,0) == "\") ? "*" : "" ) . """ "
	}
    }
    
    ;debug: MsgBox curBasePath: %curBasePath%`nfilesList: «%filesList%»
    ; because of following, only m1 and m3 are viable
    ;archiving r:\Depts Office Workstations\User Data\CommOps-Head\Marina\ (~18 Gb)
    ; 7-Zip LZMA2:	2 hours, 9.3 GB
    ; zpaq m1:	20 min,	10.2 GB
    ; zpaq m2:	55 min,	 9.9 GB
    ; zpaq m3:	55 min,  8.8 GB
    ; zpaq m4: 2h 15 m,	 8.4 GB
    
    ;WaitCPUIdle(zpaqPID)
    Run %comspec% /U /C "CHCP 65001 & START "" /B /WAIT /D "\\?\%curBasePath%" %zpaqexe% a "%3%%arcName%.m3.zpaq" %filesList% -m3 2>>"%3%%arcName%.m3.errors.log" %redirCmd% "%3%%arcName%.m3.log" %cmdSuffix%",%curBasePath%,Min,zpaqPID
}

ExitApp

WaitCPUIdle(pidToWait:=0, cpuLimit := 0.7, limitDuration := 15, processWaitTimeout := 120) {
    FileAppend Start waiting for idle CPU`n, *
    GetIdleTime()
    c:=0
    Loop
    {
	Sleep 1000
	idle := GetIdleTime()
	If (idle > cpuLimit)
	    c++
	Else
	    c := 0
    } Until c > limitDuration || (A_Index > processWaitTimeout && !ProcessExist(pidToWait))
}

;http://www.autohotkey.com/board/topic/11910-cpu-usage/
GetIdleTime()    ;idle time fraction
{
    Static oldIdleTime, oldKrnlTime, oldUserTime
    Static newIdleTime, newKrnlTime, newUserTime

    oldIdleTime := newIdleTime
    oldKrnlTime := newKrnlTime
    oldUserTime := newUserTime

    DllCall("GetSystemTimes", "int64P", newIdleTime, "int64P", newKrnlTime, "int64P", newUserTime)
    Return (newIdleTime-oldIdleTime)/(newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)
}

ProcessExist(pid) {
    Process Exist, %pid%
    return ErrorLevel
}

CommonPath(dir1, dir2) {
    dir1shn:=SubStr(dir1, 1, StrLen(dir2))
    dir2shn:=SubStr(dir2, 1, StrLen(dir1))
    If (dir1shn = dir2shn) {
	return dir1shn
    }
    
    Loop Parse, dir1shn, \
    {
	newCommonPath .= (A_Index > 1 ? "\" : "") . A_LoopField
	If (SubStr(dir2shn, 1, StrLen(newCommonPath)) != newCommonPath)
	    return commonPath
	commonPath:=newCommonPath
    }
    Throw "Should not happen"
}

Findzpaqexe() {
    If (A_Is64bitOS)
	namezpexe=zpaq64.exe
    Else
	namezpexe=zpaq.exe
    
    dirs=
    (LTrim Join;
    %A_ScriptDir%
    %LocalAppData%\Programs\Arc\zpaq
    %LocalAppData%\Programs\Arc\zpaq*\*
    %Path%
    )
    
    return FindExeInDirs(namezpexe, dirs)
}

FindTeeExe() {
    dirs=
    (LTrim Join;
    %A_ScriptDir%
    %SystemDrive%\SysUtils\UnxUtils
    %Path%
    )
    return FindExeInDirs("tee.exe", dirs)
}

FindExeInDirs(exe, dirs) {
    Loop Parse, dirs, `;
    {
	If (SubStr(A_LoopField, -1)=="\*") {
	    r := "R"
	    dir := SubStr(A_LoopField, 1, -2)
	} Else {
	    r=
	    dir := A_LoopField
	}
	Loop Files, %A_LoopField%, D%r%
	{
	    curPath := A_LoopFileFullPath . "\" . exe
	    If (FileExist(curPath)) {
		FileGetTime curTime, %curPath%
		If (curTime > maxTime) {
		    maxPath:=curPath, maxTime:=curTime
		}
	    }
	}
    }
    
    If (!maxPath)
	Throw exe . " not found in " . dirs
    return maxPath
}
