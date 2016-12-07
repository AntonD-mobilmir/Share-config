#NoEnv
#SingleInstance off

if not A_IsAdmin
{
    EnvGet RunInteractiveInstalls, RunInteractiveInstalls
    If RunInteractiveInstalls!=0
    {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	Run *RunAs %ScriptRunCommand% ; Requires v1.0.92.01+
	ExitApp
    }
}

TargetDir=%A_ProgramFiles%\Notepad2
LinkSource=%TargetDir%\notepad2.exe
LinkTarget=%A_ProgramFiles%\Total Commander\notepad2.exe
LogFile=`%TEMP`%\%A_ScriptName%.log

Loop, %A_ScriptDir%\Special and Custom Editions\notepad2-mod.googlecode\Notepad2-mod.*_x86-32_Setup.exe
{
    Distributive=%A_LoopFileLongPath%
    Break    
}
exe7z := find7z()
Run, %comspec% /C ""%exe7z%" x -aoa -y -o"%TargetDir%" -- "%Distributive%">%LogFile%",,Hide UseErrorLevel
If ErrorLevel
{
    IfEqual, ErrorLevel, ERROR
	OutputDebug, System Error when run unpack: %A_LastError%
    Else
	OutputDebug, Error when run unpack: %ErrorLevel%
	
    MsgBox ErrorLevel: %ErrorLevel%`nSystem Error: %A_LastError%
}
Else
    FileDelete, %LogFile%

IfExist, %LinkTarget%
{
    FileMove, %LinkTarget%, %LinkTarget%.bak, 1
    If ErrorLevel
	FileDelete %LinkTarget%
    ;either successfully moved or ErrorLevel set by FileDelete
    If ErrorLevel
	MsgBox Can neither move nor delete %LinkTarget%
}

Result := DllCall("CreateHardLink", Str, LinkTarget, Str, LinkSource, Int, 0)
If (!Result or ErrorLevel or A_LastError)
    MsgBox, Result: %Result%`nErrorLevel: %ErrorLevel%`nSystem Error: %A_LastError%

Run, Notepad2-install.cmd, %TargetDir%

Exit

;Kernel32.dll
;BOOL WINAPI CreateHardLink(
;  __in        LPCTSTR lpFileName,
;  __in        LPCTSTR lpExistingFileName,
;  __reserved  LPSECURITY_ATTRIBUTES lpSecurityAttributes
;);
;System Error Codes:
;http://msdn.microsoft.com/en-us/library/ms681381(v=vs.85).aspx


find7z() {
    exe7z := Check7zExt(".7z")
    IfExist %exe7z%
	return exe7z

    Try {
	exe7z := findexe("7z.exe","c:\Program Files\7-Zip","c:\Program Files (x86)\7-Zip","c:\Arc\7-Zip")
	return exe7z
    }

    Try {
	exe7z := findexe("7za.exe","c:\Program Files\7-Zip","c:\Program Files (x86)\7-Zip","c:\Arc\7-Zip")
	return exe7z
    }
    
    Throw "Could not find 7-Zip"
}

Check7zExt(fext) {
    SetRegView 64
    RegRead progid, HKEY_CLASSES_ROOT\%fext%
    If (!progid)
	 RegRead progid, HKEY_CURRENT_USER\Software\Classes\%fext%
    If (!progid)
	 RegRead progid, HKEY_CLASSES_ROOT\VirtualStore\MACHINE\SOFTWARE\Classes\%fext%
    return Check7zFileType(progid)
}

Check7zFileType(progid) {
    exe7zFM:=ProgIdToExe(progid)
    SplitPath exe7zFM,, exe7zDir
    exe7zDir:=LTrim(exe7zDir,"""")
    
    exe7z=%exe7zDir%\7z.exe
    exe7za=%exe7zDir%\7za.exe
    IfExist %exe7z%
	return exe7z
    IfExist %exe7za%
	return exe7za

    Throw "Path to 7-Zip not found via ProgID " . progid
}

ProgIdToExe(progid) {
    RegRead shellopencmd, HKEY_CLASSES_ROOT\%progid%\Shell\Open\Command
    If (!shellopencmd)
	RegRead shellopencmd, HKEY_LOCAL_MACHINE\SOFTWARE\Classes\%progid%\Shell\Open\Command
    If (!shellopencmd)
	RegRead shellopencmd, HKEY_CLASSES_ROOT\VirtualStore\MACHINE\SOFTWARE\Classes\%progid%\Shell\Open\Command
	
    return Get1stToken(shellopencmd)
}

Get1stToken(src, delimeter:=" ") {
    inquote:=false
    Loop Parse, src
    {
	If (A_LoopField=="""")
	    inquote:=!inquote
	Else If (A_LoopField==delimeter && !inquote) {
	    return SubStr(src, 1, A_Index)
	}
    }
    return src
}

findexe(exe, paths*) {
    ; exe is name only or full path
    ; paths are additional full paths, dirs or path-masks to check for
    ; first check if executable is in %PATH%

    Loop Files, %exe%
	return A_LoopFileLongPath
    
    SplitPath exe, exename, , exeext
    If (exeext=="") {
	exe .= ".exe"
	exename .= ".exe"
    }
    
    Try return GetPathForFile(exe, paths*)
    
    RegRead AppPath, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exename%
    If (!ErrorLevel)
	IfExist %AppPath%
	    return AppPath
    RegRead AppPath, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exename%
    If (!ErrorLevel)
	IfExist %AppPath%
	    return AppPath
    
    EnvGet Path,PATH
    Try return GetPathForFile(exe, StrSplit(Path,";")*)
    
    EnvGet utilsdir,utilsdir
    If (utilsdir)
	Try return GetPathForFile(exe, utilsdir)
    
    ;Look for registered apps
    Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\Applications\" . exename)
    Loop Reg, HKEY_CLASSES_ROOT\, K
    {
	Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\" . %A_LoopRegName%)
    }
    
    Try return GetPathForFile(exe, A_ScriptDir . "..\..\..\Distributives\Soft\PreInstalled\utils"
				 , A_ScriptDir . "..\..\Soft\PreInstalled\utils"
				 , "\Distributives\Soft\PreInstalled\utils"
				 , "\\localhost\Distributives\Soft\PreInstalled\utils"
				 , "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils" )
    
    Throw 0
}

GetPathForFile(file, paths*) {
    For i,path in paths {
	Loop Files, %path%, D
	{
	    fullpath=%A_LoopFileLongPath%\%file%
	    IfExist %fullpath%
		return fullpath
	}
    }
    
    Throw
}

GetAppPathFromRegShellKey(exename, regsubKeyShell) {
    regsubKey=%regsubKeyShell%\shell
    Loop Reg, %regsubKey%, K
    {
	RegRead regAppRun, %regsubKey%\%A_LoopRegName%\Command
	regpath := RemoveParameters(regAppRun)
	SplitPath regpath, regexe
	If (exename=regexe)
	    IfExist %regpath%
		return regpath
    }
    Throw
}

RemoveParameters(runStr) {
    QuotedFlag=0
    Loop Parse, runStr, %A_Space%
    {
	AppPathOnly .= A_LoopField
	IfInString A_LoopField, "
	    QuotedFlag:=!QuotedFlag
	If Not QuotedFlag
	    break
	AppPathOnly .= A_Space
    }
    return Trim(AppPathOnly, """")
}
