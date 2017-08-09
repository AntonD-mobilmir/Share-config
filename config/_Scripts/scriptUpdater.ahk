#NoEnv
#SingleInstance ignore

;usage:
;to update separately signed script:
;    scriptUpdater.ahk destFullPath URL [CheckPeriod]
;to update common script:
;    scriptUpdater.ahk destMask [CheckPeriod] [ScriptsMask [CheckPeriod] …]

; Ссылки на подпапки в dropbox непредсказуемы (обычный путь не допишешь), поэтому выкладывать папку / делать к ней доступ нет смысла
; вместо этого, если URL не указан, скрипт должен быть в архиве https://www.dropbox.com/s/an5nvf0hrofva7r/ScriptUpdater.7z.gpg?dl=1

CommonGPGFName := "ScriptUpdater.7z.gpg"
CommonScriptsURL := "https://www.dropbox.com/s/jec74kwu40wjqgm/" CommonGPGFName "?dl=1"
СfgDir := "D:\Local_Scripts\ScriptUpdater"
GNUPGHOME := CfgDir "\gnupg"

timeout := 15 ; seconds
tries := 15

tempDir := A_Temp "\" A_ScriptName ".tmp"
FileCreateDir %tempDir%

; самообновление
;UpdateScript(A_ScriptFullPath, 48, CommonScriptsURL, CommonGPGFName)
UpdateScript("D:\*", 48, CommonScriptsURL, CommonGPGFName)

clURL = %2%
If (StartsWith(clURL, "http")) {
    checkPeriod = %3%
    destPath = %1%
    ExitApp UpdateScript(destPath, checkPeriod, clURL)
    ;URL, gpgFName
} Else {
    nexti=
    Loop %0%
    {
	If (checkPeriod) { ; on prev loop, current arg was the checkPeriod
	    checkPeriod=
	    continue
	}
	
	nexti := A_Index+1
	checkPeriod := %nexti%
	If checkPeriod is not Integer
	    checkPeriod=
	
	Loop Files, % %A_Index%
	    UpdateScript(A_LoopFileLongPath, checkPeriod, CommonScriptsURL, CommonGPGFName)
    }
}

ExitApp

UpdateScript(dstFullPath, checkPeriod, URL, gpgFName := "") {
    global tempDir, GNUPGHOME, timeout, tries
    static curlexe, wgetexe
	 , nextMethod:=2
	 , gpgexe := findexe("gpg.exe", "c:\SysUtils\gnupg\pub")
	 , exe7z

    If (!checkPeriod)
	checkPeriod := 24 ; Hours
    
    SplitPath dstFullPath, dstFName, dstDir,,, drvltr ; drvltr is either d: or \\hostname (no ending backslash)
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
    
    runLog = %tempDir%\%dstFName%.UpdateRunning.log
    endLog = %tempDir%\%dstFName%.Update.log
    
    FileGetTime ctime, %endLog%, C
    FileGetTime ctimeUpdRun, %runLog%, C
    If (ctimeUpdRun > ctime)
	ctime := ctimeUpdRun
    checkAge=
    checkAge -= ctime, Hours
    If (checkAge > 0 && checkAge < checkPeriod)
	return 2
    FileGetSize runLogSize, %runLog%
    If (runLogSize > 1048576)
	FileDelete %runLog%
    FileAppend %A_Now% Downloading %URL% to update "%dstFullPath%"…`n, %runLog%
    ;FileSetTime,, %endLog%, C
    
    Loop %tries% ; tries
    {
	Try {
	    curMethod := Mod(A_Index+nextMethod, 3)
	    If (curMethod==0) {
		If (!curlexe)
		    curlexe := findexe("curl.exe")
		RunWait %curlexe% -qvfL --compressed -m %timeout% -b "%tempDir%\curl-cookies.txt" -c "%tempDir%\curl-cookies.txt" -z "%dstFullPath%" -o "%tempDir%\%gpgFName%" %URL%, %tempDir%, Hide
	    } Else If (curMethod==1) {
		If (!wgetexe)
		    wgetexe := findexe("wget.exe")
		RunWait %wgetexe% --no-config -d -T %timeout% --load-cookies="%tempDir%\wget-cookies.txt" --save-cookies="%tempDir%\wget-cookies.txt" -O "%tempDir%\%gpgFName%" %URL%, %tempDir%, Hide
	    } Else If (curMethod==2) {
		URLDownloadToFile %URL%, %tempDir%\%gpgFName%
	    }
	} catch e {
	    continue
	}
	
	FileDelete "%tempDir%\%verifiedFName%"
	EnvSet GNUPGHOME, %GNUPGHOME%
	RunWait %comspec% /C ""%gpgexe%" --homedir "%GNUPGHOME%" --batch -o "%tempDir%\%verifiedFName%" -d "%tempDir%\%gpgFName%" 2>"%tempDir%\%gpgFName%.log"", %tempDir%, Hide
	gpgErrLevel := ErrorLevel
	FileRead gpglog, %tempDir%\%gpgFName%.log
	FileAppend `n%gpglog%`n, %runLog%
	If (!gpgErrLevel && RegexMatch(gpglog, "^gpg: Signature made (?P<MM>\d+)/(?P<DD>\d+)/(?P<YY>\d+) (?P<Hour>\d+):(?P<Min>\d+):(?P<Sec>\d+) .+ key ID (?P<keyID>\w+)$", r)) {
	    ;gpg: Signature made 08/09/17 13:59:40 Russia TZ 2 Standard Time using DSA key ID E91EA97A
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
		FileAppend %A_Now% Unpacking "%archSubdir%\%dstFName%" from "%verifiedFName%"…
		RunWait %exe7z% x -o"%drvltr%" -- "%tempDir%\%verifiedFName%" "%archSubdir%\%dstFName%",, Hide UseErrorLevel
		;Code Meaning 
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
