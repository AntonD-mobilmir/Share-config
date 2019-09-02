;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance force
#Persistent
minAgeForSendLogs := 2 ; days
idletimeDisconnectVPN := 30 * 60 * 1000 ; 30 min in ms
idletimeRarusCheckAutoLoad := 3 * 60 * 1000 ; 3 min in ms
doublepressRarusTimeout := 20 * 60 * 1000 ; 20 min in ms
idletimeGiftomanNonOnTop := 30 * 1000 ; 30 s in ms
rebootOfferDelay := 60 * 60 * 1000 ; 1h in ms
maxIdleForMsgbox := timerPeriod := 3000 ; ms
startDay := A_DD
sizeLimitLog1S := 500 ; MB
dirLog1S := "d:\1S\1С8_Розница\Действующая\1Cv8Log"
pathLog1S := dirLog1S "\1Cv8.lgd"

EnvGet SystemRoot,SystemRoot
EnvGet LocalAppData,LOCALAPPDATA
EnvGet lProgramFiles, ProgramFiles(x86)
lProgramFiles := lProgramFiles ? lProgramFiles : A_ProgramFiles
Thread NoTimers
If (A_IsAdmin)
    Menu Tray, Icon

If (FileExist(lProgramFiles "\Canon\MF Scan Utility\MFSCANUTILITY.exe"))
    checkCanonMFScan := -1 ; PID скрипта исправления ACL. Скрипт будет запущен при обнаружении MFSCANUTILITY.exe, если процесса с таким PID нет.

If (InStr(FileExist(dirLog1S), "D")) {
    FileGetSize sizeLog1S, %pathLog1S%, M
    If (sizeLog1S > sizeLimitLog1S) {
        FileMove %pathLog1S%, %pathLog1S%.bak, 1
        If (A_OSVersion != "WIN_7" && A_OSVersion != "WIN_VISTA" && A_OSVersion != "WIN_2003" && A_OSVersion != "WIN_XP" && A_OSVersion != "WIN_2000")
            Run %SystemRoot%\System32\compact.exe /C /F /EXE:LZX "%pathLog1S%.bak", %dirLog1S%, Hide UseErrorLevel
    }
    Run %SystemRoot%\System32\compact.exe /C /S /I "%dirLog1S%", %dirLog1S%, Hide UseErrorLevel
}

;ahk_class HwndWrapper[KKMGMSuite.exe;;ec6679dd-7266-4fe0-8880-fd566da471b0]
;ahk_exe KKMGMSuite.exe
GroupAdd KKMGMSuite, ahk_exe KKMGMSuite.exe

;Progress A M R0-%idletimeRarusCheckAutoLoad% T, idle
SetTimer Periodic, %timerPeriod%

; Разрешение запуска PepperFlash из папки настроек Chrome пользователя
RunWait %SystemRoot%\System32\icacls.exe "%LocalAppData%\Google\Chrome\User Data\PepperFlash" /grant "%A_UserName%:(OI)(CI)M" /T /C, %A_Temp%, Min UseErrorLevel

; Удаление дистрибутивов OneDrive – иначе со временем их скачивается много версий и они занимают гигабайты
FileRemoveDir %LocalAppData%\Microsoft\OneDrive, 1

;save a bit on memory if Windows 5 or newer - MilesAhead
DllCall("psapi.dll\EmptyWorkingSet", "Int", -1, "Int")

Exit

Periodic:
    ;idle := A_TimeIdlePhysical
    idle := A_TimeIdle ; на действия самого скрипта тоже стоит реагировать
    ;Progress %idle%, %idle%
    If (idle > idletimeDisconnectVPN) {
	If (!RasDisconnected)
	    Run rasdial.exe /DISCONNECT,,Min UseErrorLevel
	;rasdial [entryname] /DISCONNECT
	RasDisconnected:=1
    } Else {
	RasDisconnected=
	
	If (checkCanonMFScan) {
	    Process Exist, MFSCANUTILITY.exe
	    If (ErrorLevel) { ; если утилита запущена
		Process Exist, %checkCanonMFScan%
		If (!ErrorLevel) ; а скрипт – не запущен
		    Run "%A_AhkPath%" "%A_ScriptDir%\Reset ACL after Canon MF Scan Utility.ahk",,,checkCanonMFScan
	    }
	}
    }
    
;Гифтоман
    If (giftomanWinExist || idle > idletimeGiftomanNonOnTop) {
        giftomanWinExist := WinExist("ahk_group KKMGMSuite")
        If (giftomanWinExist) {
            If (transp < 255 && WinActive()) {
                WinSet Transparent, Off
                transp := 255
            } Else {
                WinSet AlwaysOnTop, Off
                If (transp > 50)
                    WinSet Transparent, % transp >>= 1
            }
        }
    }
return

getFirstPid(exeNames*) {
    For i,Name in exeNames {
	Process Exist, %Name%
	If (ErrorLevel)
	    return ErrorLevel
    }
    return
}

;\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\getDefaultConfig.ahk
getDefaultConfigFileName(defCfg := -1) {
    If (defCfg==-1)
	defCfg := getDefaultConfig()
    SplitPath defCfg, OutFileName
    return OutFileName
}

getDefaultConfigDir(defCfg := -1) {
    If (defCfg==-1) {
        EnvGet configDir, configDir
	If (configDir)
	    return RTrim(configDir, "\")
	defCfg := getDefaultConfig()
    }
    SplitPath defCfg,,OutDir
    return OutDir
}

getDefaultConfig(batchPath := -1) {
    If (batchPath == -1) {
	EnvGet DefaultsSource, DefaultsSource
	If (DefaultsSource)
	    return DefaultsSource
	Try {
	    return getDefaultConfig(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd")
	}
	EnvGet SystemDrive, SystemDrive
	return getDefaultConfig(SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd")
    } Else {
	return ReadSetVarFromBatchFile(batchPath, "DefaultsSource")
    }
}

;\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	If (RegExMatch(A_LoopReadLine, "i)SET\s+(?P<Name>.+)\s*=(?P<Value>.+)", m)) {
	    If (Trim(Trim(mName), """") = varname) {
		return Trim(Trim(mValue), """")
	    }
	}
    }
    Throw Exception("Var not found",, varname)
}


;http://www.autohotkey.com/board/topic/75390-ahk-l-unicode-uri-encode-url-encode-function/
; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959)
UriEncode(Uri, Enc = "UTF-8") {
    Res := ""
	StrPutVar(Uri, Var, Enc)
	f := A_FormatInteger
	SetFormat, IntegerFast, H
	Loop
	{
		Code := NumGet(Var, A_Index - 1, "UChar")
		If (!Code)
			Break
		If (Code >= 0x30 && Code <= 0x39 ; 0-9
			|| Code >= 0x41 && Code <= 0x5A ; A-Z
			|| Code >= 0x61 && Code <= 0x7A) ; a-z
			Res .= Chr(Code)
		Else
			Res .= "%" . SubStr(Code + 0x100, -1)
	}
	SetFormat, IntegerFast, %f%
	Return, Res
}

UriDecode(Uri, Enc = "UTF-8") {
	Pos := 1
	Loop
	{
		Pos := RegExMatch(Uri, "i)(?:%[\da-f]{2})+", Code, Pos++)
		If (Pos = 0)
			Break
		VarSetCapacity(Var, StrLen(Code) // 3, 0)
		StringTrimLeft, Code, Code, 1
		Loop, Parse, Code, `%
			NumPut("0x" . A_LoopField, Var, A_Index - 1, "UChar")
		StringReplace, Uri, Uri, `%%Code%, % StrGet(&Var, Enc), All
	}
	Return, Uri
}

StrPutVar(Str, ByRef Var, Enc = "") {
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}
