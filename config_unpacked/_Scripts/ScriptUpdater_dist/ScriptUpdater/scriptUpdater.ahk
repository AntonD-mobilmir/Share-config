#NoEnv
#SingleInstance off
#NoTrayIcon
;#Warn
;ToDo: off only for debugging --
#ErrorStdOut
FileEncoding UTF-8

;usage:
;to update separately signed script:
;    scriptUpdater.ahk destFullPath URL [CheckPeriod]
;to update a SharedLocal script:
;    scriptUpdater.ahk destMask [CheckPeriod] [destMask [CheckPeriod] …]

; Ссылки на подпапки в dropbox непредсказуемы (обычный путь не допишешь), поэтому выкладывать папку / делать к ней доступ нет смысла
; вместо этого, если URL не указан, скрипт должен быть в архиве https://www.dropbox.com/s/an5nvf0hrofva7r/SharedLocal.7z.gpg?dl=1

GNUPGHOME := A_ScriptDir "\gnupg"
;GNUPGHOME = D:\Local_Scripts\ScriptUpdater\gnupg
;If (!InStr(FileExist(GNUPGHOME), "D"))
;    GNUPGHOME = %A_AppDataCommon%\mobilmir.ru\ScriptUpdater\gnupg
global childPID := 0
OnExit("KillChild")

If (!FileExist(GNUPGHOME "\private-keys-v1.d\*.key")) {
    FileGetSize secringSize, %GNUPGHOME%\secring.gpg
    If (ErrorLevel || !secringSize)
	Throw Exception("Secring not generated yet")
}
timeout := 15 ; seconds
tries := 15

tempDir := A_Temp "\" A_ScriptName ".tmp"
FileCreateDir %tempDir%
EnvGet LocalAppData, LOCALAPPDATA
If (!LocalAppData)
    LocalAppData := A_AppData
confDir := LocalAppData "\mobilmir.ru\" A_ScriptName
FileCreateDir %confDir%

If (!IsObject(FileOpen(GNUPGHOME "\lock.tmp", "w"))) { ; 
    FileCopyDir %GNUPGHOME%, %tempDir%\gnupg, 1
    FileAppend Cannot write to GNUPGHOME ("%GNUPGHOME%")`, copying keyring to TEMP ("%TEMP%")`n, *, CP1
    GNUPGHOME = %tempDir%\gnupg
}
FileDelete GNUPGHOME "\lock.tmp"
EnvSet GNUPGHOME, %GNUPGHOME%

FileAppend tempDir: %tempDir%`nconfDir: %confDir%`nGNUPGHOME: %GNUPGHOME%`ntimeout: %timeout%`ntries: %tries%`n, *, CP1
clURL = %2%
If (StartsWith(clURL, "http")) {
    destPath = %1%
    checkPeriod = %3%
    gpgFName = %4%
    If (gpgFName=="" && (InStr(destPath, "*") || InStr(destPath, "?"))) { ; if destPath is not mask, UpdateScript will use destPath filename to generate GPG filename
	RegexMatch(clURL, "/([^/?#]+)([#?].+)$", m)
	gpgFName := m1
    }
    ExitApp UpdateScript(destPath, checkPeriod, clURL, gpgFName)
} Else {
    SharedLocalGPGFName := "SharedLocal.7z.gpg"
    SharedLocalScriptsURL := "https://www.dropbox.com/s/jec74kwu40wjqgm/" SharedLocalGPGFName "?dl=1"
    checkPeriod=
    Loop %0%
    {
	If (checkPeriod) { ; on prev loop, current arg was the checkPeriod
	    checkPeriod=
	    continue
	}
	
	ni := A_Index+1
	If %ni% is Integer
	    checkPeriod := %ni%
	
	Loop Files, % %A_Index%
	    UpdateScript(A_LoopFileLongPath, checkPeriod, SharedLocalScriptsURL, SharedLocalGPGFName)
    }
}

; самообновление – через autoupdate.cmd
;If (A_IsAdmin)
;    UpdateScript(A_ScriptFullPath, 48, "https://www.dropbox.com/s/y6xpm8xgcovkffg/ScriptUpdater.7z.gpg?dl=1", "ScriptUpdater.7z.gpg")
;UpdateScript("D:\*", 48, SharedLocalScriptsURL, SharedLocalGPGFName)

ExitApp

UpdateScript(dstFullPath, checkPeriod, URL, gpgFName := "") {
    global tempDir, confDir, GNUPGHOME, timeout, tries
    static curlexe := "", wgetexe := "", exe7z := ""
	 , gpgexe  := findexe("gpg.exe", "c:\SysUtils\gnupg", "c:\SysUtils\gnupg\pub")
	 , nextMethod:=2
    If (checkPeriod=="")
	checkPeriod := 24 ; Hours
    
    SplitPath dstFullPath, dstFName, dstDir, dstExt,, drvltr ; drvltr is either d: or \\hostname (no ending backslash)
    If (StartsWith(drvltr, "\\"))
	return 0
    If (gpgFName) {
	SplitPath gpgFName, , , , verifiedFName
	If (dstFName != verifiedFName)
	    tryUnpack := 1
    } Else {
	gpgFName := dstFName ".gpg"
	verifiedFName := dstFName
    }
    FileAppend dstFullPath: %dstFullPath%`ncheckPeriod: %checkPeriod%`nURL: %URL%`ngpgFName: %gpgFName%`nverifiedFName: %verifiedFName%`n, *, CP1
    
    endLog = %confDir%\%verifiedFName%.Update.log
    runLog = %confDir%\%verifiedFName%.UpdateRunning.log
    
    FileGetTime ctime, %endLog%, C
    FileGetTime ctimeUpdRun, %runLog%, C
    If (ctimeUpdRun > ctime)
	ctime := ctimeUpdRun
    If (ctime) {
	checkAge=
	checkAge -= ctime, Hours
	If (checkAge >= 0 && checkAge < checkPeriod) {
	    FileAppend %A_Now% Last check %checkAge% hours ago`, min %checkPeriod% h needed`n, %runLog%
	    return 1
	}
    }
    FileGetSize runLogSize, %runLog%
    If (runLogSize > 1048576)
	FileMove %runLog%, %runLog%.bak, 1
    FileAppend %A_Now% Downloading %URL% to update "%dstFullPath%" due to last check %checkAge% hours ago…`n, %runLog%
    ;FileSetTime,, %endLog%, C
    
    Loop %tries% ; tries
    {
	Try {
	    curMethod := Mod(A_Index+nextMethod, 3)
	    If (curMethod==0) {
		If (!curlexe)
		    curlexe := findexe("curl.exe")
		RunWait %curlexe% -qvfL --compressed -m %timeout% -b "%confDir%\curl-cookies.txt" -c "%confDir%\curl-cookies.txt" -z "%dstFullPath%" -o "%tempDir%\%gpgFName%" %URL%, %tempDir%, Hide, childPID
	    } Else If (curMethod==1) {
		If (!wgetexe)
		    wgetexe := findexe("wget.exe")
		RunWait %wgetexe% --no-config -d -T %timeout% --load-cookies="%confDir%\wget-cookies.txt" --save-cookies="%confDir%\wget-cookies.txt" -O "%tempDir%\%gpgFName%" %URL%, %tempDir%, Hide, childPID
	    } Else If (curMethod==2) {
		URLDownloadToFile %URL%, %tempDir%\%gpgFName%
	    }
	    childPID := 0
	    If (ErrorLevel)
		continue
	} catch e {
	    continue
	}
	
	FileDelete %tempDir%\%verifiedFName%
	; --never-lock unsupported
	cmdlgpg = "%gpgexe%" --homedir "%GNUPGHOME%" --batch --pinentry-mode loopback -o "%verifiedFName%" -d "%gpgFName%"
	FileAppend %A_Now% > %cmdlgpg%`n, *, CP1
	FileAppend %A_Now% > %cmdlgpg%`n, %runLog%
	RunWait %comspec% /C "ECHO.|%cmdlgpg% 2>"%gpgFName%.log"", %tempDir%, Hide, childPID
	gpgErrLevel := ErrorLevel, childPID := 0
	Loop 15
	{
	    gpglog=
	    Try {
		FileRead gpglog, *P1 %tempDir%\%gpgFName%.log
		If (!gpglog)
		    gpglog := "(file """ tempDir "\" gpgFName ".log"" is empty)"
	    } Catch e {
		FileAppend % A_Now " Error " e.Message "(" e.Extra ") reading " gpgFName ".log, retrying…`n", %runLog%
		RunWait %A_WinDir%\system32\taskkill.exe /F /PID %childPID% /T,,Hide UseErrorLevel
		Sleep 1000
	    }
	} Until gpglog
	FileAppend %gpglog%`nErrorLevel: %gpgErrLevel%`n, %runLog%
	;MsgBox gpgErrLevel: %gpgErrLevel%`ngpglog:`n%gpglog%
	If (!gpgErrLevel
	    && ( dstExt="mab"
	      || RegexMatch(gpglog, "m`a)^gpg: Signature made (?P<MM>\d+)/(?P<DD>\d+)/(?P<YY>\d+) (?P<Hour>\d+):(?P<Min>\d+):(?P<Sec>\d+).+\s\s?.+using (?P<KeyType>\w+) key (?P<keyID>[A-Z0-9]+).+\s\s?gpg: Good signature from .+ \[(?P<trust>\w+)\]", r)
	      || RegexMatch(gpglog, "^gpg: Signature made (?P<MM>\d+)/(?P<DD>\d+)/(?P<YY>\d+) (?P<Hour>\d+):(?P<Min>\d+):(?P<Sec>\d+).+using (?P<KeyType>\w+) key ID (?P<keyID>\w+)\s+gpg: Good signature from .+ \[(?P<trust>\w+)\]", r)
	      || RegexMatch(gpglog, "m`a)Good signature from .+ \[(?P<trust>\w+)\]", r) )) {
	    If  (rtrust = "unknown")
		Throw Exception("Trust level: " rtrust,, r)
	    ; old GPG:
	    ;gpg: Signature made 08/09/17 19:26:49 Russia TZ 2 Standard Time using DSA key ID E91EA97A
	    ;gpg: Good signature from "Антон Дербенев (Цифроград-Ставрополь) <anton.derbenev@mobilmir.ru>" [ultimate]
	    ; 
	    ; new GPG:					   ↓ ANSI encoding ("зима")
	    ;gpg: Signature made 10/12/17 16:07:40 RTZ 2 (чшьр)
	    ;gpg:                using DSA key 535A11463B4577A5B3D38421861A68CCE91EA97A
	    ;gpg: Good signature from "Антон Дербенев (Цифроград-Ставрополь) <anton.derbenev@mobilmir.ru>" [ultimate]
	    ;				↑ DOS encoding
	    FileSetTime SubStr("2000", 1, 4-StrLen(rYY)) . Format("{:02u}{:02u}{:02u}{:02u}{:02u}{:02u}", rYY, rMM, rDD, rHour, rMin, rSec), %tempDir%\%verifiedFName%
	    nextMethod := A_Index + 1 ; чтобы текущий метод оказался первым при следующем вызове UpdateScript
	    
	    If (tryUnpack) {
		If (!exe7z) {
		    EnvGet exe7z, exe7z
		    exe7z := Trim(exe7z, """")
		    If (!FileExist(exe7z)) {
			Try
			    exe7z:=find7zexe()
			Catch
			    exe7z:=find7zaexe()
		    }
		}

		cmdl7z = "%exe7z%" x -y -o"%dstDir%" -- "%tempDir%\%verifiedFName%" "%dstFName%" 
		FileAppend %A_Now% > %cmdl7z%`n, *, CP1
		FileAppend %A_Now% > %cmdl7z%`t…, %runLog%
		RunWait %comspec% /C "%cmdl7z% >>"%runLog%" 2>&1", %tempDir%, Hide UseErrorLevel, childPID
		childPID := 0
		;ErrorLevel Meaning 
		;0 No error 
		;1 Warning (Non fatal error(s)). For example, one or more files were locked by some other application, so they were not compressed. 
		;2 Fatal error 
		;7 Command line error 
		;8 Not enough memory for operation 
		;255 User stopped the process 
		
		If (!CheckErrorLevel(runLog, endLog) < 2)
		    return 1
	    }
	    
	    FileAppend %A_Now% Copying "%verifiedFName%" to "%dstFullPath%"… , %runLog%
	    FileCopy %tempDir%\%verifiedFName%, %dstFullPath%.tmp, 1
	    If (!ErrorLevel)
		FileMove %dstFullPath%.tmp, %dstFullPath%, 1
	    return !CheckErrorLevel(runLog, endLog)
	}
    }
    
    return 0
}

StartsWith(long, short) {
    return short = SubStr(long, 1, StrLen(short))
}

CheckErrorLevel(runLog, endLog:="", e:="") {
    If (e=="")
	e:=ErrorLevel
    If (e) {
	FileAppend Error %ErrorLevel%, %runLog%
    } Else {
	FileAppend OK`n, %runLog%
	FileMove %runLog%, %endLog%, 1
    }
    
    return e
}

KillChild() {
    Process WaitClose, gpg-agent.exe, 3
    If (ErrorLevel) {
	GroupAdd gpgagent, ahk_exe gpg-agent.exe
	WinKill ahk_group gpgagent
	Process Close, gpg-agent.exe
    }
    If (childPID)
	Process Close, %childPID%
}

find7zexe(exename="7z.exe", paths*) {
    ;key, value, flag "this is path to exe (only use directory)"
    regPaths := [["HKEY_CLASSES_ROOT\7-Zip.7z\shell\open\command",,1]
		,["HKEY_CURRENT_USER\Software\7-Zip", "Path"]
		,["HKEY_LOCAL_MACHINE\Software\7-Zip", "Path"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe", "Path"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe",,1]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "InstallLocation"]
		,["HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip", "UninstallString", 1] ]
    
    bakRegView := A_RegView
    For i,regpath in regPaths
    {
	SetRegView 64
	RegRead currpath, % regpath[1], % regpath[2]
	SetRegView %bakRegView%
	If (regpath[3]) 
	    SplitPath currpath,,currpath
	Try return Check7zDir(exename, Trim(currpath,""""))
    }
    
    findexefunc=findexe
    If(IsFunc(findexefunc)) {
	EnvGet ProgramFilesx86,ProgramFiles(x86)
	EnvGet SystemDrive,SystemDrive
	Try return %findexefunc%(exename, ProgramFiles . "\7-Zip", ProgramFilesx86 . "\7-Zip", SystemDrive . "\Program Files\7-Zip", SystemDrive . "\Arc\7-Zip")
	Try return %findexefunc%("7za.exe", SystemDrive . "\Arc\7-Zip")
    }
    
    For i,path in paths {
	Loop Files, %path%, D
	{
	    fullpath=%A_LoopFileLongPath%\%exename%
	    IfExist %fullpath%
		return fullpath
	}
    }
    
    Throw exename " not found"
}

Check7zDir(exename,dir7z) {
    If(SubStr(dir7z,0)=="\")
	dir7z:=SubStr(dir7z,1,-1)
    If (!FileExist(exe7z := dir7z "\" exename))
	Throw exename " not found in " dir7z
    return exe7z
}

find7zaexe(paths:="") {
    If(paths=="")
	paths := []
    paths.push("\Distributives\Soft\PreInstalled\utils"
             , "D:\Distributives\Soft\PreInstalled\utils"
             , "W:\Distributives\Soft\PreInstalled\utils"
             , "\\localhost\Distributives\Soft\PreInstalled\utils"
             , "\\Srv1S-B.office0.mobilmir\Distributives\Soft\PreInstalled\utils"
             , "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils"
             , "\\192.168.1.80\Distributives\Soft\PreInstalled\utils")
    return find7zexe("7za.exe",paths*)
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
    
    Try {
	RegRead AppPath, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exename%
	IfExist %AppPath%
	    return AppPath
    }
    
    Try {
	RegRead AppPath, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\%exename%
	IfExist %AppPath%
	    return AppPath
    }
    
    EnvGet Path,PATH
    Try return GetPathForFile(exe, StrSplit(Path,";")*)
    
    EnvGet utilsdir,utilsdir
    If (utilsdir)
	Try return GetPathForFile(exe, utilsdir)
    
    ;Look for registered apps
    Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\Applications\" . exename)
    Loop Reg, HKEY_CLASSES_ROOT\, K
    {
	Try return GetAppPathFromRegShellKey(exename, "HKEY_CLASSES_ROOT\" . A_LoopRegName)
    }
    
    Try return GetPathForFile(exe, A_LineFile . "..\..\..\..\..\..\Distributives\Soft\PreInstalled\utils" ; Srv0 only
				 , A_LineFile . "..\..\..\..\Programs" ; Srv0 only
				 , A_LineFile . "..\..\..\..\Soft\PreInstalled\utils" ; in retail, when config and soft are in D:\Distributives
				 , A_LineFile . "..\..\..\..\..\Distributives\Soft\PreInstalled\utils" ; in retail, for case when config is in some other dir
				 , "\Distributives\Soft\PreInstalled\utils" ; same
				 , "\\localhost\Distributives\Soft\PreInstalled\utils" ; sometimes Distributives are somewhere else but available on net
				 , "\\Srv0.office0.mobilmir\Distributives\Soft\PreInstalled\utils" ; almost last resort, only works in office0
				 , "\\Srv0.office0.mobilmir\profiles$\Share\Programs" ) ; last resort, only works in office0

    EnvGet SystemDrive,SystemDrive
    Loop Files, %SystemDrive%\SysUtils\%exename%, R
	return A_LoopFileLongPath
    
    Throw { Message: "Requested execuable not found", What: A_ThisFunc, Extra: exe }
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
