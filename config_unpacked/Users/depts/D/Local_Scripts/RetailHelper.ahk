;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv
#NoTrayIcon
#SingleInstance force
#Persistent
Thread NoTimers

idletimeDisconnectVPN := 30 * 60 * 1000 ; 30 min in ms
idletimeRarusCheckAutoLoad := 3 * 60 * 1000 ; 3 min in ms
doublepressRarusTimeout := 20 * 60 * 1000 ; 20 min in ms
idletimeGiftomanNonOnTop := 30 * 1000 ; 30 s in ms
rebootOfferDelay := 60 * 60 * 1000 ; 1h in ms
maxIdleForMsgbox := timerPeriod := 3000 ; ms
startDay := A_DD
wintitle1s=ahk_exe 1cv7s.exe
EnvGet lProgramFiles, ProgramFiles(x86)
If (!lProgramFiles)
    lProgramFiles := A_ProgramFiles
If (FileExist(lProgramFiles "\Canon\MF Scan Utility\MFSCANUTILITY.exe"))
    checkCanonMFScan := -1 ; PID скрипта исправления ACL. Скрипт будет запущен при обнаружении MFSCANUTILITY.exe, если процесса с таким PID нет.

timeTillEndOfDay := A_YYYY . A_MM . A_DD
timeTillEndOfDay += 1, Days
timeTillEndOfDay -= A_Now, Seconds

nextRebootOffer := A_TickCount + TimeTillEndOfDay * 1000 ; ms

;ahk_class HwndWrapper[KKMGMSuite.exe;;ec6679dd-7266-4fe0-8880-fd566da471b0]
;ahk_exe KKMGMSuite.exe
GroupAdd KKMGMSuite, ahk_exe KKMGMSuite.exe

;Progress A M R0-%idletimeRarusCheckAutoLoad% T, idle
SetTimer Periodic, %timerPeriod%

; Разрешение запуска PepperFlash из папки настроек Chrome пользователя
EnvGet LocalAppData,LOCALAPPDATA
RunWait %A_WinDir%\System32\icacls.exe "%LocalAppData%\Google\Chrome\User Data\PepperFlash" /grant "%A_UserName%:(OI)(CI)M" /T /C, %A_Temp%, Min UseErrorLevel

; Проверка флагов ошибок при отправке выгрузок
foundErrFlags=
Loop Files, d:\1S\Rarus\ShopBTS\ExtForms\post\DispatchFiles.ahk.log*.errflag
{
    FileReadLine errLine, %A_LoopFileFullPath%, 1
    foundErrFlags .= A_LoopFileName ": " errLine ", "
}
If (foundErrFlags)
    foundErrFlags := "Флаги ошибок: " SubStr(foundErrFlags, 1, -2) "."
unsentCounts:={}
For mask, name in {"OutgoingText\*.txt": "уведомления", "OutgoingFiles\*.*": "выгрузки"}
    Loop Files, d:\1S\Rarus\ShopBTS\ExtForms\post\%mask%
    {
	age=
	age -= A_LoopFileTimeModified, Days
	If (!unsentCounts.HasKey(name))
	    unsentCounts[name] := 0
	unsentCounts[name] += age > 2
    }
unsentCountsText=
For name, c in unsentCounts
    If (c)
	unsentCountsText .= name " (" c "), "
If (unsentCountsText)
    foundErrFlags := "Есть не отправленные в течение двух дней " SubStr(unsentCountsText, 1, -2) ". " foundErrFlags
If (foundErrFlags) {
    ;\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\RetailStatusReport.ahk  <Module> <Status> <Extended info …>
    Try Run % """" A_AhkPath """ """ getDefaultConfigDir() "\_Scripts\Lib\RetailStatusReport.ahk"" """ A_ScriptName """ ""Rarus email system malfunction"" """ StrReplace(StrReplace(foundErrFlags, """", "'"), "`n", "; ") """"
    MsgBox 0x30, Ошибки при отправке выгрузок или уведомлений из 1С-Рарус, При отправке выгрузок или увеодмлений из 1С-Рарус возникли ошибки`, и отправка частично либо полностью не работает.`n`nПри закрытии этого окна`, откроется шаблон письма для регистрации заявки. Проверьте его`, добавьте известную Вам информацию и отправляйте. Если письмо не отправится – звоните.
    Run % "mailto:it-task@status.mobilmir.ru?subject=Ошибки%20отправки%20выгрузок%20или%20уведомлений%20из%201С-Рарус%20&body=Обнаружены%20сигнальные%20файлы%20ошибок%20при%20отправке%20выгрузок%20или%20уведомлений%20из%201С-Рарус%3A%0A%0A" UriEncode(foundErrFlags)
}

If (A_IsAdmin)
    ExitApp
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
	If (rarusPID && A_TickCount >= nextRebootOffer && A_TimeIdlePhysical > maxIdleForMsgbox) {
	    MsgBox 0x34, Компьютер не перезагружался, Компьютер включен со вчерашнего дня.`nДля создания резервной копии 1С-Рарус требуется перезагрузка. Перезагрузить сейчас?`n`n(если ответите нет – перезагрузите сами при первой возможности), 60
	    IfMsgBox No
	    {
		nextRebootOffer := A_TickCount + rebootOfferDelay ; ms
	    } Else {
		WinClose %wintitle1s%
		WinWaitClose,,, 30 ; seconds to wait for close
		Shutdown 2
	    }
	} Else {
	    rarusPID := getFirstPid("1cv7s.exe", "1cv7.exe")
	}
	
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
    If (idle > idletimeGiftomanNonOnTop && WinExist("ahk_group KKMGMSuite")) {
	If (transp > 50)
	    transp-=10
	IfWinActive
	{
	    WinSet Transparent, %transp%
	    WinSet AlwaysOnTop, Off
	} Else {
	    transp:=255
	    WinSet Transparent, Off
	}
    }
;Рарус
    If (idle > idletimeRarusCheckAutoLoad && A_TickCount > rarusLoadNextCheck && WinExist(wintitle1s)) {
	rarusMinMax := 2
	ControlGetText txtBtn, Button20
	If (ErrorLevel || txtBtn != "ОБМЕН УТ") {
	    WinGet rarusMinMax, MinMax
	    If (rarusMinMax == -1)
		WinRestore
	    ControlSend ahk_parent, {F12}
	    ;Progress,, Фронт кассира развернут
	    Sleep 2000
	    ControlGetText txtBtn, Button20
	    If (ErrorLevel || txtBtn != "ОБМЕН УТ") ; че-то не сработало
		Exit
	}
	ControlGetText txtStatic, Static2
	If (ErrorLevel || txtStatic != "ОБМЕН УТ")
	    Exit
	; кроме Static2, можно проверять видимость Button21, но Button21 -- без текста
	ControlGet s2vis, Visible,, Static2
	If (!ErrorLevel && s2vis) { ; кнопка – красная
	    If (rarusMinMax == 2) {
		WinGet rarusMinMax, MinMax
		If (rarusMinMax == -1)
		    WinRestore
	    }
	    ControlClick Button20 ; ОБМЕН УТ
	    rarusLoadNextCheck := A_TickCount + doublepressRarusTimeout
	}
	If (rarusMinMax = -1)
	    WinMinimize
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
