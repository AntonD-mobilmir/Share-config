
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

; это исходное ошибочное предположение. А вообще, DOL2 использует только одно значение – RootDir. -- Loop Reg, %DOL2SettingsKey%
RegRead dol2regRootDir, %DOL2SettingsKey%, RootDir

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

If (!CrystalReportsInstalled())
    ShowError("CrystalReports не установлен", "Без CrystalReports не будет работать печать договоров.")

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
    return SubStr(long,1,StrLen(short))=short
}

; начальные проверки закончены, можно запускать
runAppAgain:
Run "%ProgramFilesx86%\Internet Explorer\iexplore.exe" https://dealer.beeline.ru/dealer/DOL2/DOL.application

SplashTextOn 250,50,%ScriptTitle%, DOL2 запущен`, ожидается появление окна (обычно до двух минут)
WinSet AlwaysOnTop, Off, %ScriptTitle%

DOLNavigatorErrors := ["Не удалось соединиться с Ядром системы (localhost:2000). Не удалось определить значение ключа 'LogMask' в таблице конфигурации"
		      ,"Обновление базы данных прошло с ошибкой. Приложение не будет запущено!",
		      ,"Не удалось соединиться с Ядром системы (localhost:2000). Ожидание закончилось вследствие освобождения семафора."
		      ,"Отказано в доступе по пути"]

;For i,wintext in DOLNavigatorErrors
;    GroupAdd grpDOLNavigatorErrors, On Line Dealer ahk_class #32770 ahk_exe DOLNavigator.exe, %wintext%

Loop
{
    Sleep 500
    
    IfWinExist Невозможно запустить приложение ahk_exe dfsvc.exe
    {
	ControlClick &OK
	configDir := getDefaultConfigDir()
	RunWait "%ComSpec%" /C "%configDir%\_Scripts\Security\FSACL_DOL2.cmd",,Min
	GoTo runAppAgain
    }

    IfWinExist Cannot Start Application ahk_exe dfsvc.exe, Application cannot be started. Contact the application vendor.
    {
	ControlClick &OK
	configDir := getDefaultConfigDir()
	RunWait "%ComSpec%" /C "%configDir%\_Scripts\Security\FSACL_DOL2.cmd",,Min
	GoTo runAppAgain
    }

    IfWinExist Обзор папок ahk_class #32770 ahk_exe DOLNavigator.exe, Выберите папку для хранения данных приложения DOL:
    {
	SplashTextOff
	Progress A M ZH0, %DOL2ReqdBaseDir%,В окне выбора папки укажите:,%ScriptTitle%
	
	Loop
	{
	    Sleep 500
	    RegRead dol2regRootDir, %DOL2SettingsKey%, RootDir
	} Until !ErrorLevel
	Progress Off
	
	If (dol2regRootDir!=DOL2ReqdBaseDir) {
	    Process Close, DOLNavigator.exe
	    RegDelete %DOL2SettingsKey%, RootDir
	    RegDelete HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\DB, Ver
	    ShowError("Выбрана папка """ . dol2regRootDir . """", "Вы отменили выбор или выбрали не ту папку.")
	    ExitApp
	}
	
	Continue
    }
    
    IfWinExist Установка DOL ahk_class #32770 ahk_exe DOLNavigator.exe, Этот компьютер будет использоваться для установки с него клиентского приложения DOL и обновлений на другие компьютеры в локальной сети?
    {
	ControlClick &Нет
	ControlClick Button2
	Continue
    }
    
    IfWinExist DOL Навигатор - (Дилер: ahk_exe DOLNavigator.exe
	break
    
    IfWinExist Навигатор ahk_exe DOLNavigator.exe, menuMain
	continue ; ещё не запустился
    
    IfWinExist ahk_exe DOLNavigator.exe
    {
	WinGetTitle fullTitle
	WinGetText fullText
	SplashTextOff
	
	FileAppend %A_Now% Обнаружено окно: [%fullTitle%]`n%fullText%`n`n
	
	;IfWinExist ahk_group grpDOLNavigatorErrors
	For i,wintext in DOLNavigatorErrors {
	    If (InStr(fullText, wintext)) {
		ShowError("Обнаружено окно DOLNavigator с ошибкой """ . wintext . """")
		ExitApp
	    }
	}
	
	ShowError("Обнаружено неизвестное окно DOLNavigator: " . fullTitle . "`n" . fullText, "Описания этого окна нет в скрипте запуска.")
    }
}

SplashTextOff

;FileSetAttrib +H, %A_Programs%\Vimpelcom, 2
FileRemoveDir %A_Programs%\Vimpelcom

ExitApp

BeginsWith(long, short) {
    return short = SubStr(long, 1, StrLen(short))
}

ShowError(text, explain:="", title:="") {
    global ScriptTitle, logfname
    If (!title)
	title:=ScriptTitle
    FileAppend %A_Now%: %text%`n, %logfname%
    
    endTime := A_TickCount + 5 * 60 * 1000 ; 5 минут
    Run http://l.mobilmir.ru/newtaskdept
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
