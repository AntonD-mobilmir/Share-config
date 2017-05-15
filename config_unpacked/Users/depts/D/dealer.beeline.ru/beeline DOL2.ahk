#NoEnv
#SingleInstance off
SetRegView 32

ScriptTitle=Скрипт проверки запуска DOL2
logfname=%A_ScriptFullPath%.log
DOL2SettingsRegRoot=HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line
DOL2SettingsKey=%DOL2SettingsRegRoot%\Contract\Dirs
DOL2ReqdBaseDir=d:\dealer.beeline.ru\DOL2

EnvGet ProgramFilesx86,ProgramFiles(x86)
IfNotExist %ProgramFilesx86%
    EnvGet ProgramFilesx86,ProgramFiles

; подготовка
DOL2exe=DOLNavigator.exe
DOL2NavErrTitle = On Line Dealer ahk_class #32770 ahk_exe %DOL2exe%

; список окон для наблюдения
; ключ - текст в окне или заголовок окна (сначала проверяется текст)
; значение – объект []
;	1: заголовок окна (или пусто, если ключ = заголовок)
;	2: требуемое действие
;		-1 – показать сообщение об ошибке и открыть окно для регистрации заявки для службы ИТ
;		 0 – всё ок, завершить скрипт
;	 	 1 – выбор папки
;		 2 – нажать OK, запустить FSACL_DOL2.cmd, перезапустить DOL2
; 		 3 – нажать Нет
;		 4 – подождать и проверить снова
AutoResponces := {"DOL Навигатор - (Дилер: ahk_exe " . DOL2exe: ["", 0]
    ,"Не удалось соединиться с Ядром системы (localhost:2000). Не удалось определить значение ключа 'LogMask' в таблице конфигурации": [DOL2NavErrTitle, -1]
    ,"Обновление базы данных прошло с ошибкой. Приложение не будет запущено!"							: [DOL2NavErrTitle, -1]
    ,"Не удалось соединиться с Ядром системы (localhost:2000). Ожидание закончилось вследствие освобождения семафора."		: [DOL2NavErrTitle, -1]
    ,"Отказано в доступе по пути"												: [DOL2NavErrTitle, -1]
    ,"Запуск приложения невозможен. Обратитесь к поставщику приложения."	: ["Невозможно запустить приложение ahk_exe dfsvc.exe", 2]
    ,"Application cannot be started. Contact the application vendor."		: ["Cannot Start Application ahk_exe dfsvc.exe", 2]
    ,"Скачивание приложения не выполнено. Проверьте сетевое подключение или обратитесь к системному администратору или поставщику сетевых услуг." : ["Невозможно запустить приложение ahk_exe dfsvc.exe", -1]
    ,"Этот компьютер будет использоваться для установки с него клиентского приложения DOL и обновлений на другие компьютеры в локальной сети?": ["Установка DOL ahk_class #32770 ahk_exe " . DOL2exe, 3]
    ,"menuMain": ["Навигатор ahk_exe " . DOL2exe, 4]}

;если окно DOL2 обнаружено, оно просто будет активировано, а запуск выполняться не будет
If (WinExist("ahk_exe " . DOL2exe)) {
    WinSet AlwaysOnTop, On
    WinActivate
    WinSet AlwaysOnTop, Off
    ExitApp
}

GroupAdd WinWaitList, ahk_exe %DOL2exe%
For wintext,v in AutoResponces
    If (v[1])
	If (!InStr(v[1], "ahk_exe " . DOL2exe))
	    GroupAdd WinWaitList, % v[1], %wintext%
    Else
	If (!InStr(wintext, "ahk_exe " . DOL2exe))
	    GroupAdd WinWaitList, %wintext%

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
    MsgBox 0x40, %ScriptTitle%, Вы запускаете DOL2 первый раз. Должна была открыться инструкция по настройке DOL2 при первом запуске`, если этого не произошло`, перейдите по ссылке: http://l.mobilmir.ru/DOL2FirstRun`n`nЕсли DOL2 не настроить по инструкции`, он может не работать нормально`, а договоры могут теряться.
} Else {
    If (dol2regRootDir != DOL2ReqdBaseDir) {
	ShowError("В качестве корневой папки указана: " . dol2regRootDir, "Если при первом запуске DOL2 не указать папку D:\dealer.beeline.ru\DOL2, настройки и договора не будут сохраняться в резервной копии и могут быть случайно или автоматически удалены или утеряны при переносе данных на другой компьютер.", "В настройках DOL2 есть ошибка!")
	ExitApp
    }

    RegRead dol2master, %DOL2SettingsRegRoot%\System, Master
    If (dol2master) {
	ShowError("При первом запуске DOL2 было указано, что с компьютера будут устанавливаться обновления на другие компьютеры")
	RegWrite REG_DWORD, HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\System, Master, 0
    }
}

; начальные проверки закончены, можно запускать
Loop
{
    If (!started) {
	Run "%ProgramFilesx86%\Internet Explorer\iexplore.exe" https://dealer.beeline.ru/dealer/DOL2/DOL.application
	started:=1
	SplashTextOn 250,50,%ScriptTitle%, DOL2 запущен`, ожидается появление окна (обычно до двух минут)
	WinSet AlwaysOnTop, Off, %ScriptTitle%
    }
    
    WinWait ahk_group WinWaitList,,300
    If (ErrorLevel) {
	MsgBox За пять минут ни одно ожидаемое окно не появилось.
	ExitApp
    } Else {
	WinGetTitle fullTitle
	WinGetText fullText
	FileAppend %A_Now% Обнаружено окно: [%fullTitle%]`n%fullText%`n`n, %logfname%
	SplashTextOff
	a=
	For wintext,v in AutoResponces {
	    If (v[1] && InStr(fullText, wintext) || InStr(fullTitle, SubStr(wintext, 1, InStr(wintext, " ahk_")-1))) {
		a:=v[2]
		If (a=0) {
		    ;FileSetAttrib +H, %A_Programs%\Vimpelcom, 2
		    FileRemoveDir %A_Programs%\Vimpelcom
		    ExitApp
		} Else If (a=-1) {
		    WinGet exeName, ProcessName
		    ;WinGet exePath, ProcessPath
		    ;SplitPath exePath, exeName
		    ShowError("Обнаружено окно " . exeName . " с ошибкой """ . wintext . """")
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
			Process Close, %DOL2exe%
			RegDelete %DOL2SettingsKey%, RootDir
			RegDelete HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\DB, Ver
			ShowError("Выбрана папка """ . dol2regRootDir . """", "Вы отменили выбор или выбрали не ту папку.")
			ExitApp
		    }
		} Else If (a=2) {
		    ControlClick &OK
		    If (!configDir)
			configDir := getDefaultConfigDir()
		    RunWait "%ComSpec%" /C "%configDir%\_Scripts\Security\FSACL_DOL2.cmd",,Min
		    started := 0
		} Else If (a=3) {
		    ControlClick &Нет
		    ControlClick Button2
		} Else If (a=4) {
		    Sleep 500
		}
	    }
	}
	If (!a)
	    ShowError("Обнаружено неизвестное окно DOLNavigator: " . fullTitle . "`n" . fullText, "Описания этого окна нет в скрипте запуска.")
    }
}
ShowError("Выполнение цикла мониторинга прекратилось", "В скрипте запуска DOL2 есть ошибка")
ExitApp

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

StartsWith(ByRef long, ByRef short) {
    return SubStr(long, 1, StrLen(short)) = short
}

ShowError(text, explain:="", title:="") {
    global ScriptTitle, logfname
    If (!title)
	title:=ScriptTitle
    FileAppend %A_Now%: %text%`n, %logfname%
    
    endTime := A_TickCount + 5 * 60 * 1000 ; 5 минут
    ;Run http://l.mobilmir.ru/newtaskdept
    If (textcrpos := InStr(text, "`n")) {
	mailTitle := SubStr(text, 1, textcrpos-1)
    } Else {
	mailTitle := text
    }
    Run % "mailto:it-task@status.mobilmir.ru?subject=" . UriEncode("Ошибка при запуске DOL2 на \\" . A_ComputerName . ": " . mailTitle) . "&body=" . UriEncode(text . "`n`n(" . explain . ")")
    MsgBox 0x1030, %title%, %text%.`n%explain%`nНезамедлительно сообщите в службу ИТ и не используйте DOL2 на этом компьютере до исправления.
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
