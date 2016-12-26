;script invokes zpaq, intended to be run by totalcmd.exe
;after setting up in usercmd.ini

;command line: zpaq.ahk <cmd> <utf8 files list> <destination>
; <cmd>	: a,l or x
; <utf8 files list> : path to геа8 text file which contains newline-delimeted list files to be processed by zpaq
; <destination> : path to destination folder for a and x commands (in case of l, it is ignored)

;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

FileEncoding UTF-8

Global Path,LocalAppData
EnvGet Path,PATH
EnvGet LocalAppData,LOCALAPPDATA

zpaqexe := """" . Findzpaqexe() . """"
cmd=%1%

If (cmd="l")
    tmpListFile=%A_Temp%\%A_ScriptName%-list.%A_Now%.txt

Loop Read, %2%
{
    SplitPath A_LoopReadLine, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
    If (cmd="x") {
	RunWait %zpaqexe% x "%A_LoopReadLine%" -to "%3%%OutNameNoExt%"
    } Else If (cmd="l") {
	RunWait %comspec% /C "%zpaqexe% l "%A_LoopReadLine%" >> "%tmpListFile%"",,Min
    } Else If (cmd="a") {
	files .= """" . A_LoopReadLine . "\*"" "
	If (A_Index=1) {
	    arcName=%OutFileName%
	    curBasePath:=OutDir
	} Else {
	    arcName=
	    curBasePath := CommonPath(curBasePath, OutDir)
	}
    } Else {
	MsgBox Command unsupported: %cmd%
    }
}

If (cmd="l") {
    Run "%tmpListFile%"
} Else If (cmd="a") {
    If (!arcName)
	If (curBasePath)
	    SplitPath curBasePath, arcName
	Else
	    arcName:=A_Now
    Run %comspec% /C "%zpaqexe% a "%3%%arcName%.zpaq" %files% || PAUSE"
}

ExitApp

CommonPath(dir1, dir2) {
    dir1shn:=SubStr(dir1, 1, StrLen(dir2))
    dir2shn:=SubStr(dir2, 1, StrLen(dir1))
    If (dir1shn = dir2shn) {
	return dir1shn
    }
    
    Loop Parse, dir1shn, \
    {
	newCommonPath .= A_LoopField . "\"
	If (SubStr(dir2shn, 1, StrLen(newCommonPath)) != newCommonPath)
	    return SubStr(commonPath, 1, -1)
	commonPath:=newCommonPath
    }
    Throw "Should not happen"
}

Findzpaqexe() {
    If (A_Is64bitOS)
	namezpexe=zpaq64.exe
    Else
	namezpexe=zpaq.exe
    
    SearchDirs=
    (LTrim Join;
    %A_ScriptDir%
    %LocalAppData%\Programs\Arc\zpaq
    %LocalAppData%\Programs\Arc\zpaq*
    %Path%
    )
    
    Loop Parse, SearchDirs, `;
    {
	Loop Files, %A_LoopField%, D
	{
	    curPath := A_LoopFileFullPath . "\" . namezpexe
	    If (FileExist(curPath)) {
		FileGetTime curTime, %curPath%
		If (curTime > maxTime) {
		    maxPath:=curPath, maxTime:=curTime
		}
	    }
	}
    }
    
    If (!maxPath)
	Throw "zpaq.exe not found"
    return maxPath
}
