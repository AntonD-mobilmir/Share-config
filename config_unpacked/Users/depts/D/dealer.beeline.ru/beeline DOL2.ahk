#NoEnv
#SingleInstance force
FileEncoding UTF-8
MyPID:=DllCall("GetCurrentProcessId")
SetRegView 32

EnvGet ProgramFilesx86,ProgramFiles(x86)
IfNotExist %ProgramFilesx86%
    EnvGet ProgramFilesx86,ProgramFiles

EnvGet LocalAppData,LOCALAPPDATA
If (!LocalAppData) {
    EnvGet UserProfile,USERPROFILE
    LocalAppData=%UserProfile%\Local Settings\Application Data
}

ScriptTitle=Скрипт проверки запуска DOL2
logfname=%A_ScriptFullPath%.log
DOL2SettingsRegRoot=HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line
DOL2SettingsKey=%DOL2SettingsRegRoot%\Contract\Dirs
DOL2ReqdBaseDir=%A_ScriptDir%\DOL2
DOL2BinDir=%LocalAppData%\Apps\2.0
DOL2Navexe=DOLNavigator.exe
DOL2NavErrTitle = On Line Dealer ahk_class #32770
startDelay := 1000 ; пауза после запуска URL. Удваивается после каждого запуска.
unkCount := 3 ; сколько раз можно обнаружить неизвестное окно, прежде чем сообщать
MaxMailtoTextLength := 1024

; подготовка

; список окон для наблюдения
; [[exe, заголовок окна, текст в окне, требуемое действие], […], …]
; 	требуемое действие:
;		-1 – показать сообщение об ошибке и открыть окно для регистрации заявки для службы ИТ
;		 0 – всё ок, завершить скрипт
;	 	 1 – выбор папки
;		 2 – нажать OK, запустить FSACL_DOL2.cmd, перезапустить DOL2
; 		 3 – нажать Нет
;		 4 – подождать и проверить снова
;		 5 – дождаться закрытия
;		 6 – &Установить
;		 7 - OK, удалить
;		 8 - Отмена
AutoResponces := [[DOL2Navexe, "DOL Навигатор - (Дилер:", "", 0]
    ,[DOL2Navexe, "On Line Dealer", "Закончить работу?", 0]
    ,[DOL2Navexe, "On Line Dealer", "Не удалось соединиться с Ядром системы (localhost:2000). Не удалось запустить модуль Ядра системы", 2]
    ,[DOL2Navexe, "Обзор папок", "Выберите папку для хранения данных приложения DOL:", 1]
    ,[DOL2Navexe, "Установка DOL ahk_class #32770", "Этот компьютер будет использоваться для установки с него клиентского приложения DOL и обновлений на другие компьютеры в локальной сети?", 3]
    ,[DOL2Navexe, DOL2NavErrTitle, "Не удалось соединиться с Ядром системы (localhost:2000). Не удалось определить значение ключа 'LogMask' в таблице конфигурации", -1]
    ,[DOL2Navexe, DOL2NavErrTitle, "Обновление базы данных прошло с ошибкой. Приложение не будет запущено!" , -1]
    ,[DOL2Navexe, DOL2NavErrTitle, "Не удалось соединиться с Ядром системы (localhost:2000). Ожидание закончилось вследствие освобождения семафора.", -1]
    ,[DOL2Navexe, DOL2NavErrTitle, "Отказано в доступе по пути" , -1]
    ,["dfsvc.exe", "Невозможно запустить приложение", "Запуск приложения невозможен. Обратитесь к поставщику приложения." , 2]
    ,["dfsvc.exe", "Невозможно запустить приложение", "Невозможно запустить приложение. Обратитесь за помощью к поставщику приложения." , 2]
    ,["dfsvc.exe", "Cannot Start Application", "Application cannot be started. Contact the application vendor." , 2]
    ,["dfsvc.exe", "Невозможно запустить приложение", "Скачивание приложения не выполнено. Проверьте сетевое подключение или обратитесь к системному администратору или поставщику сетевых услуг.", -1]
    ,["dfsvc.exe", "Установка приложения - Предупреждение о безопасности", "SIGNER CLIENT DOL" , 6] ; предложение установить
    ,["dfsvc.exe", "Невозможно запустить приложение", "Приложение DOL уже установлено из другого расположения. Удалите DOL." , 7] ; требование удалить
    ,["dfsvc.exe", "(", "Установка DOL", 4] ; скачивание, заголовок окна: "(…%) Установка DOL"
    ,["dfsvc.exe", "(100%) Установка DOL", "", 4] ; скачивание, заголовок окна: "(…%) Установка DOL"
    ,[DOL2Navexe, "Настройки Навигатора On Line Dealer", "Вести журнал" , 0] ; #INC-5766
    ,[DOL2Navexe, "Навигатор", "menuMain", 0] ; окно DOL2 уже появилось, но ещё не заполнено
    ,[DOL2Navexe, "Выполнение задач", "", 0] ; если стоит галочка "выполнять при запуске"
    ,["rundll32.exe", "Оповещение системы безопасности Windows", "Отмена", 8]]

;если окно DOL2 обнаружено, оно просто будет активировано, а запуск выполняться не будет
If (WinExist("ahk_exe " . DOL2Navexe)) {
    WinSet AlwaysOnTop, On
    WinActivate
    WinSet AlwaysOnTop, Off
    ExitApp
}

If (!InStr(FileExist(DOL2BinDir), "D")) {
    FileCreateDir %DOL2BinDir%
    run_FSACL_DOL2_cmd()
}

GroupAdd WinWaitList, ahk_exe %DOL2Navexe%
For i,v in AutoResponces
    If (v[1] != DOL2Navexe)
	GroupAdd WinWaitList, % v[2] " ahk_exe " v[1], % v[3]

If (!CrystalReportsInstalled())
    ShowError("CrystalReports не установлен", "Без CrystalReports не будет работать печать договоров.")

; проверка выбранной корневой папки
RegRead dol2regRootDir, %DOL2SettingsKey%, RootDir
; исходное ошибочное предположение. Вообще-то DOL2 использует только одно значение – RootDir. -- Loop Reg, %DOL2SettingsKey%

If (ErrorLevel) {
    ;RootDir не указан = DOL2 ещё не запускался
    FileAppend %A_Now%: У пользователя %A_UserName% настроек в реестре нет`n, %logfname%
    Run http://l.mobilmir.ru/DOL2FirstRun
    ;RegWrite REG_SZ, %DOL2SettingsKey%, RootDir, %DOL2ReqdBaseDir%
    RegWrite REG_DWORD, %DOL2SettingsRegRoot%\System, Master, 0
    MsgBox 0x41, %ScriptTitle%, Вы запускаете DOL2 первый раз. Должна была открыться инструкция по настройке DOL2 при первом запуске`, если этого не произошло`, перейдите по ссылке: http://l.mobilmir.ru/DOL2FirstRun`n`nЕсли DOL2 не настроить по инструкции`, он может не работать нормально`, а договоры могут теряться.
    IfMsgBox Cancel
	ExitApp
    
    If (!WinExist(DOL2ReqdBaseDir . "DATA\DB.mdb")) {
	; распаковка DOL2.template.7z → DOL2\
	If (!exe7z){
	    If (!configDir)
		configDir := getDefaultConfigDir()
	    tempFile=%A_Temp%\%A_ScriptName%.exe7zpath.tmp
	    FileAppend %A_Now% exe7z=, %logfname%
	    RunWait %comspec% /C ""%A_AhkPath%" /ErrorStdOut "%configDir%\_Scripts\Lib\find7zexe.ahk" > "%tempFile%"",%A_Temp%,Min
	    FileReadLine exe7z, %tempFile%, 1
	    If (!FileExist(exe7z))
		Throw "7-Zip не найден, распаковать шаблон настроек невозможно"
	    FileAppend "%exe7z%"`n, %logfname%
	}
	RunWait %comspec% /C ""%exe7z%" x -o"%DOL2ReqdBaseDir%" -- "%A_ScriptDir%\DOL2.template.7z" >>"%logfname%" 2>&1", %A_ScriptDir%, Min
	;7-Zip returns the following exit codes:
	;Code Meaning 
	;0 No error 
	;1 Warning (Non fatal error(s)). For example, one or more files were locked by some other application, so they were not compressed. 
	;2 Fatal error 
	;7 Command line error 
	;8 Not enough memory for operation 
	;255 User stopped the process 
	If (ErrorLevel < 2 && FileExist(DOL2ReqdBaseDir "\DOL2.reg")) {
	    ; импорт DOL2\DOL2.reg
	    RunWait %comspec% /C ""%A_WinDir%\system32\reg.exe" IMPORT "%DOL2ReqdBaseDir%\DOL2.reg" >>"%logfname%" 2>&1", %DOL2ReqdBaseDir%, Min
	    FileDelete %DOL2ReqdBaseDir%\DOL2.reg
	    ; запись действительного пути в [HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs] "RootDir" (REG_SZ)
	    RegWrite REG_SZ, HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\Contract\Dirs, RootDir, %DOL2ReqdBaseDir%
	} Else {
	    FileAppend %A_Now% Шаблон БД не распакован. Импорт настроек и запись пути в реестр выполнена не будет`, пользователю придется самостоятельно выбрать правильную папку.`n, %logfname%
	}
    }
} Else {
    If (dol2regRootDir != DOL2ReqdBaseDir) {
	ShowError("В качестве корневой папки указана: " . dol2regRootDir, "Если при первом запуске DOL2 не указать папку " . DOL2ReqdBaseDir . ", настройки и договора не будут сохраняться в резервной копии и могут быть случайно или автоматически удалены или утеряны при переносе данных на другой компьютер.", "В настройках DOL2 есть ошибка!")
	ExitApp
    }
    
    RegRead dol2master, %DOL2SettingsRegRoot%\System, Master
    If (dol2master) {
	FileAppend %A_Now% было [%DOL2SettingsRegRoot%\System]: Master=%dol2master% (исправлено), %logfname%
	RegWrite REG_DWORD, %DOL2SettingsRegRoot%\System, Master, 0
    }
}

; начальные проверки закончены, можно запускать
Loop
{
    If (!started) {
	Run "%ProgramFilesx86%\Internet Explorer\iexplore.exe" https://dealer.beeline.ru/dealer/DOL2/DOL.application
	started:=1
	SplashTextOn 250, 50, %ScriptTitle%, DOL2 запущен`, ожидание появления окна (обычно до двух минут)
	WinSet AlwaysOnTop, Off, %ScriptTitle% ahk_pid %MyPID%
	Sleep startDelay
	startDelay:=startDelay<<1 ; double delay each time
    }
    
    WinWait ahk_group WinWaitList,,300
    If (ErrorLevel) {
	MsgBox За пять минут ни одно ожидаемое окно не появилось.
	ExitApp
    } Else {
	WinGetTitle fullTitle
	WinGetText fullText
	WinGet exeName, ProcessName
	;WinGet exePath, ProcessPath
	;SplitPath exePath, exeName
	FileAppend %A_Now% Обнаружено окно "%exeName%": [%fullTitle%]`n%fullText%`n`n, %logfname%
	SplashTextOff
	a=
	For i,v in AutoResponces {
	    ;ahk_exe := v[1]
	    ;winTitle := v[2]
	    ;winText := v[3]
	    ;action := v[4]
	    If (exeName = v[1] && StartsWith(fullTitle, v[2]) && InStr(fullText, v[3])) {
		a:=v[4]
		If (a=0) {
		    ;FileSetAttrib +H, %A_Programs%\Vimpelcom, 2
		    FileRemoveDir %A_Programs%\Vimpelcom
		    ExitApp
		} Else If (a=-1) {
		    ShowError("Обнаружено окно " . exeName . " с ошибкой: " . fullTitle . "`n" . fullText)
		    ExitApp
		} Else If (a=1) {
		    Progress A M ZH0, %DOL2ReqdBaseDir%,В окне «Обзор папок» выберите папку,%ScriptTitle%
		    WinWaitClose
		    Progress Off
		    
		    endTime := A_TickCount + 5000 ; 5 seconds
		    Loop
		    {
			Sleep 100
			RegRead dol2regRootDir, %DOL2SettingsKey%, RootDir
		    } Until !ErrorLevel || A_TickCount > endTime
		    
		    If (dol2regRootDir!=DOL2ReqdBaseDir) { ; всё в порядке, можно проверять другие окна
			Process Close, %DOL2Navexe%
			RegDelete %DOL2SettingsKey%, RootDir
			RegDelete HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\DB, Ver
			ShowError("Выбрана папка """ . dol2regRootDir . """", "Вы отменили выбор или выбрали не ту папку.")
			ExitApp
		    }
		} Else If (a=2) {
		    ControlClick &OK
		    run_FSACL_DOL2_cmd()
		    started := 0
		} Else If (a=3) {
		    ControlClick &Нет
		    ControlClick Button2
		} Else If (a=4) {
		    Sleep 500
		} Else If (a=5) {
		    SplashTextOn 450, 150, %ScriptTitle%, Ожидание закрытия окна`n[%fullTitle%]`n%winText%
		    WinSet AlwaysOnTop, Off, %ScriptTitle% ahk_pid %MyPID%
		    WinWaitClose
		    SplashTextOff
		} Else If (a=6) {
		    If (!UninstallDOL2(started)) { ; что-то таки было удалено → окно установки было закрыто
			ControlClick &Установить
		    }
		} Else If (a=7) {
		    ControlClick &OK
		    UninstallDOL2(started)
		} Else If (a=8) {
		    ControlClick Отмена
		}
		break
	    }
	}
	If (!a) {
	    If (!unkCount--) {
		ShowError("Обнаружено неизвестное окно " . exeName . ": " . fullTitle . "`n" . fullText, "Описания этого окна нет в скрипте запуска.")
		ExitApp
	    }
	    Sleep 1000 * unkCount
	}
    }
}
ShowError("Выполнение цикла мониторинга прекратилось", "В скрипте запуска DOL2 есть ошибка")
ExitApp

UninstallDOL2(ByRef started) {
    global DOL2BinDir, DOL2Navexe
    static HKCUUninstallKey:="HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    Loop Reg, %HKCUUninstallKey%, K
    {
	currentKey:=HKCUUninstallKey "\" A_LoopRegName
	If (RegCheck(currentKey, {"DisplayName": "DOL.*"
							 ,"Publisher": "Vimpelcom"
							 ,"UrlUpdateInfo": "https://dealer.beeline.ru/dealer/DOL2/DOL.application"})) {
	    If (started) {
		WinClose ; закрытие окна установки, чтобы пользователь там ничего не нажал во время удаления
		started:=0 ; старых версий может быть несколько, закрыть окно надо только один раз
		Process Close, %DOL2Navexe%
		Process Close, DOLKernel.exe
	    }
	    RegRead UninstallString,%currentKey%,UninstallString
	    Run %UninstallString%
	    WinWait Обслуживание DOL ahk_exe dfsvc.exe
	    Sleep 500
	    ControlClick Удаление приложения с этого компьютера.
	    Sleep 200
	    ControlClick &OK
	    WinWaitClose
	    Sleep 2000
	}
    }
    If (UninstallString)
	Loop Files, %DOL2BinDir%\*, DR
	    If (FileExist(A_LoopFileFullPath . "\" . DOL2Navexe) || FileExist(A_LoopFileFullPath . "\DOLKernel.exe"))
		FileRemoveDir %A_LoopFileFullPath%, 1
    return UninstallString
}

CrystalReportsInstalled() {
    static RegViews := [32,64]
    
    bakRegView := A_RegView
    For i,RegView in RegViews {
	SetRegView %RegView%
	RegRead displayName, HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\{7C05EEDD-E565-4E2B-ADE4-0C784C17311C}, DisplayName
	If (!ErrorLevel)
	    break
    }
    
    ;Crystal Reports for .NET Framework 2.0 (x86)
    return StartsWith(displayName, "Crystal Reports for .NET Framework")
}

RegCheck(key, valuesToCheck) {
    For name, contents in valuesToCheck {
	RegRead v, %key%, %name%
	If (!(v ~= contents))
	    return 0
    }
    return 1
}

StartsWith(ByRef long, ByRef short) {
    return SubStr(long, 1, StrLen(short)) = short
}

ShowError(txt, explain:="", title:="") {
    global ScriptTitle, logfname, MaxMailtoTextLength
    If (!title)
	title:=ScriptTitle
    FileAppend %A_Now%: %txt%`n, %logfname%
    
    mailtxt	:= SubStr(txt . "`n`n" . explain, 1, MaxMailtoTextLength)
    textcrpos	:= InStr(mailtxt, "`n")
    mailTitle	:= SubStr(mailtxt, 1, textcrpos-1)
    mailtxt	:= SubStr(mailtxt, textcrpos+1)
    Run % "mailto:it-task@status.mobilmir.ru?subject=" . UriEncode("Ошибка при запуске DOL2 на \\" . A_ComputerName . ": " . mailTitle) . "&body=" . UriEncode(txt)
    MsgBox 0x1030, %title%, %txt%`n%explain%`nНезамедлительно сообщите в службу ИТ и не используйте DOL2 на этом компьютере до исправления.
}

run_FSACL_DOL2_cmd() {
    global configDir
    If (!configDir)
	configDir := getDefaultConfigDir()
    RunWait "%ComSpec%" /C "%configDir%\_Scripts\Security\FSACL_DOL2.cmd",,Min
}

;getDefaultConfig.ahk
getDefaultConfig() {
    defaultConfig := ReadSetVarFromBatchFile(A_AppDataCommon . "\mobilmir.ru\_get_defaultconfig_source.cmd", "DefaultsSource")
    If (!defaultConfig) {
	EnvGet SystemDrive, SystemDrive
	defaultConfig := ReadSetVarFromBatchFile(SystemDrive . "\Local_Scripts\_get_defaultconfig_source.cmd", "DefaultsSource")
    }
    return defaultConfig
}

getDefaultConfigFileName() {
    defaultConfig := getDefaultConfig()
    SplitPath defaultConfig, OutFileName
    return OutFileName
}

getDefaultConfigDir() {
    defaultConfig := getDefaultConfig()
    SplitPath defaultConfig,,OutDir
    return OutDir
}

;ReadSetVarFromBatchFile.ahk
ReadSetVarFromBatchFile(filename, varname) {
    Loop Read, %filename%
    {
	If (mpos := RegExMatch(A_LoopReadLine, "i)SET\s+(?P<Name>.+)\s*=(?P<Value>.+)", match)) {
	    If (Trim(Trim(matchName), """") = varname) {
		return Trim(Trim(matchValue), """")
	    }
	}
    }
}

;http://www.autohotkey.com/board/topic/75390-ahk-l-unicode-uri-encode-url-encode-function/
; modified from jackieku's code (http://www.autohotkey.com/forum/post-310959.html#310959)
UriEncode(Uri, Enc = "UTF-8")
{
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

UriDecode(Uri, Enc = "UTF-8")
{
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

StrPutVar(Str, ByRef Var, Enc = "")
{
	Len := StrPut(Str, Enc) * (Enc = "UTF-16" || Enc = "CP1200" ? 2 : 1)
	VarSetCapacity(Var, Len, 0)
	Return, StrPut(Str, &Var, Enc)
}
