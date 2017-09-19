#NoEnv
#SingleInstance off
;#Warn
;ToDo: off only for debugging --
#ErrorStdOut
FileEncoding UTF-8

;usage:
;to update separately signed script:
;    scriptUpdater.ahk destFullPath URL [CheckPeriod]
;to update common script:
;    scriptUpdater.ahk destMask [CheckPeriod] [destMask [CheckPeriod] …]

; Ссылки на подпапки в dropbox непредсказуемы (обычный путь не допишешь), поэтому выкладывать папку / делать к ней доступ нет смысла
; вместо этого, если URL не указан, скрипт должен быть в архиве https://www.dropbox.com/s/an5nvf0hrofva7r/ScriptUpdater.7z.gpg?dl=1

CommonScriptsURL := "https://www.dropbox.com/s/jec74kwu40wjqgm/" . (CommonGPGFName := "ScriptUpdater.7z.gpg") . "?dl=1"
GNUPGHOME = D:\Local_Scripts\ScriptUpdater\gnupg
If (!InStr(FileExist(GNUPGHOME), "D"))
    GNUPGHOME = %A_AppDataCommon%\mobilmir.ru\ScriptUpdater\gnupg
global childPID

FileGetSize secringSize, %GNUPGHOME%\secring.gpg
If (ErrorLevel || !secringSize)
    Throw Exception("Secring not generated yet")

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

; самообновление
If (A_IsAdmin)
    UpdateScript(A_ScriptFullPath, 48, CommonScriptsURL, CommonGPGFName)
;UpdateScript("D:\*", 48, CommonScriptsURL, CommonGPGFName)

FileAppend tempDir: %tempDir%`nconfDir: %confDir%`nGNUPGHOME: %GNUPGHOME%`ntimeout: %timeout%`ntries: %tries%`n, *, CP1
clURL = %2%
If (StartsWith(clURL, "http")) {
    checkPeriod = %3%
    destPath = %1%
    ExitApp UpdateScript(destPath, checkPeriod, clURL)
} Else {
    checkPeriod=
    Loop %0%
    {
	If (checkPeriod) { ; on prev loop, current arg was the checkPeriod
	    checkPeriod=
	    continue
	}
	
	nexti := A_Index+1
	If checkPeriod is Integer
	    checkPeriod := %nexti%
	
	Loop Files, % %A_Index%
	    UpdateScript(A_LoopFileLongPath, checkPeriod, CommonScriptsURL, CommonGPGFName)
    }
}

ExitApp

UpdateScript(dstFullPath, checkPeriod, URL, gpgFName := "") {
    global tempDir, confDir, GNUPGHOME, timeout, tries
    static curlexe := "", wgetexe := "", exe7z := ""
	 , gpgexe  := findexe("gpg.exe", "c:\SysUtils\gnupg\pub")
	 , nextMethod:=2
    If (checkPeriod=="")
	checkPeriod := 24 ; Hours
    
    SplitPath dstFullPath, dstFName, dstDir, dstExt,, drvltr ; drvltr is either d: or \\hostname (no ending backslash)
    If (StartsWith(drvltr, "\\Srv0"))
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
	FileDelete %runLog%
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
	cmdlgpg = "%gpgexe%" --homedir "%GNUPGHOME%" --batch -o "%verifiedFName%" -d "%gpgFName%"
	FileAppend %A_Now% > %cmdlgpg%`n, %runLog%
	RunWait %comspec% /C "%cmdlgpg% 2>"%gpgFName%.log"", %tempDir%, Hide, childPID
	gpgErrLevel := ErrorLevel, childPID := 0
	Loop 15
	{
	    gpglog=
	    Try {
		FileRead gpglog, *P866 %tempDir%\%gpgFName%.log
		If (!gpglog)
		    gpglog := "(file """ tempDir "\" gpgFName ".log"" is empty)"
	    } Catch e {
		FileAppend % A_Now " Error " e.Message "(" e.Extra ") reading " gpgFName ".log, retrying…`n", %runLog%
		RunWait %A_WinDir%\system32\taskkill.exe /F /PID %childPID% /T,,Min UseErrorLevel
		Sleep 1000
	    }
	} Until gpglog
	FileAppend %gpglog%`nErrorLevel: %gpgErrLevel%`n, %runLog%
	;MsgBox gpgErrLevel: %gpgErrLevel%`ngpglog:`n%gpglog%
	If (!gpgErrLevel
	    && ( dstExt="mab"
	      || RegexMatch(gpglog, "m`a)^gpg: Signature made (?P<MM>\d+)/(?P<DD>\d+)/(?P<YY>\d+) (?P<Hour>\d+):(?P<Min>\d+):(?P<Sec>\d+) .+ key ID (?P<keyID>\w+)\s+gpg: Good signature from ", r))) {
	    ;gpg: Signature made 08/09/17 19:26:49 Russia TZ 2 Standard Time using DSA key ID E91EA97A
	    ;gpg: Good signature from "Антон Дербенев (Цифроград-Ставрополь) <anton.derbenev@mobilmir.ru>" [ultimate]
	    FileSetTime SubStr("2000", 1, 4-StrLen(rYY)) . Format("{:02u}{:02u}{:02u}{:02u}{:02u}{:02u}", rYY, rMM, rDD, rHour, rMin, rSec), %tempDir%\%verifiedFName%
	    nextMethod := A_Index + 1 ; чтобы текущий метод оказался первым при следующем вызове UpdateScript
	    
	    If (tryUnpack) {
		If (!exe7z) {
		    Try
			exe7z:=find7zexe()
		    Catch
			exe7z:=find7zaexe()
		}

		archSubdir := SubStr(dstDir, StrLen(drvltr) + 2) ; 2 for next character after backslash
		FileAppend %A_Now% Unpacking "%archSubdir%\%dstFName%" from "%verifiedFName%"…, *, CP1
		FileAppend %A_Now% Unpacking "%archSubdir%\%dstFName%" from "%verifiedFName%"…, %runLog%
		cmdl7z = "%exe7z%" x -y -o"%drvltr%" -- "%tempDir%\%verifiedFName%" "%archSubdir%\%dstFName%" 
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
	    
	    FileAppend %A_Now% Moving "%verifiedFName%" to "%dstFullPath%" … , %runLog%
	    FileMove %tempDir%\%verifiedFName%, %dstFullPath%, 1
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

#include %A_LineFile%\..\Lib\find7zexe.ahk
