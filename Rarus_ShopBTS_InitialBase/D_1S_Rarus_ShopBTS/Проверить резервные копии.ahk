#NoEnv

DrivespaceFree freeRRarus,R:\Rarus

Loop Files, R:\Rarus\*.7z
{
    If (lastbackupdate < A_LoopFileTimeCreated) {
	lastbackupdate := A_LoopFileTimeCreated
	lastbackupsize := A_LoopFileSizeMB
	lastbackuppath := A_LoopFileLongPath
	lastbackupfname := A_LoopFileName
    }
}

If (lastbackuppath) {
    Try {
	exe7z:=find7z()
	Run "%exe7z%" t "%lastbackuppath%"
    } catch {
	MsgBox Тестирование архива не выполнено!
    }
    MsgBox последняя резервная копия: %lastbackupfname%`nдата: %lastbackupdate%`nразмер: %lastbackupsize% MB`nсвободное место на диске R: %freeRRarus% MB
} Else {
    MsgBox Не найдено ни одного файла из R:\Rarus\*.7z. Либо нет доступа`, либо бэкапов нет`, либо они не там.
}

find7z() {
    exe7z := Check7zExt(".7z")
    IfExist %exe7z%
	return exe7z

    Try {
	exe7z := findexe("7zg.exe","c:\Program Files\7-Zip","c:\Program Files (x86)\7-Zip","c:\Arc\7-Zip")
	return exe7z
    }
    
    If (defaultConfig)
	SplitPath defaultConfig,,configDir
    Else
	configDir := ".."
    
    Throw "7-Zip не найден"
}

Check7zFileType(progid) {
    exe7zFM:=ProgIdToExe(progid)
    SplitPath exe7zFM,, exe7zDir
    exe7zDir:=LTrim(exe7zDir,"""")
    
    exe7z=%exe7zDir%\7zg.exe
    IfExist %exe7z%
	return exe7z

    Throw "Path to 7-Zip not found via ProgID " . progid
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

;\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Ahk_Libs\findexe.ahk
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

GetAppPathFromRegShellKey(exename, regsubKeyShell) {
    regsubKey=%regsubKeyShell%\shell
;    MsgBox Looping through %regsubKey%
    Loop Reg, %regsubKey%, K
    {
;	MsgBox Reading %regsubKey%\%A_LoopRegName%\Command
	RegRead regAppRun, %regsubKey%\%A_LoopRegName%\Command
	regpath := RemoveParameters(regAppRun)
	SplitPath regpath, regexe
;	MsgBox Checking %regpath%
	If (exename=regexe)
	    IfExist %regpath%
		return regpath
    }
    Throw
}
