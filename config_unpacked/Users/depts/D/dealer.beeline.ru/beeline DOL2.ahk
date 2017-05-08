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

; это исходное ошибочное предположение. А вообще, DOL2 использует только одно значение – RootDir.
;Loop Reg, %DOL2SettingsKey%
RegRead dol2regRootDir, %DOL2SettingsKey%, RootDir

If (ErrorLevel) {
    ;RootDir не указан = DOL2 ещё не запускался
    FileAppend %A_Now%: У пользователя %A_UserName% настроек в реестре нет`n, %logfname%
    Run http://l.mobilmir.ru/DOL2FirstRun
    RegWrite REG_SZ, %DOL2SettingsKey%, RootDir, %DOL2ReqdBaseDir%
    RegWrite REG_DWORD, %DOL2SettingsRegRoot%\System, Master, 0
    MsgBox 0x40, %ScriptTitle%, Вы запускаете DOL2 первый раз. Должна была открыться инструкция по настройке DOL2 при первом запуске`, если этого не произошло`, перейдите по ссылке: http://l.mobilmir.ru/DOL2FirstRun`n`nЕсли DOL2 не настроить по инструкции`, он может не работать нормально`, а договоры могут теряться.
} Else {
    If (dol2regRootDir != DOL2ReqdBaseDir) {
	ShowError(RTrim(dirErrText, ";"), "Если при первом запуске DOL2 не указать папку D:\dealer.beeline.ru\DOL2, настройки и договора не будут сохраняться в резервной копии и могут быть случайно или автоматически удалены или утеряны при переносе данных на другой компьютер.", "В настройках DOL2 есть ошибка!")
	ExitApp
    }

    RegRead dol2master, %DOL2SettingsRegRoot%\System, Master
    If (dol2master) {
	ShowError("При первом запуске DOL2 было указано, что с компьютера будут устанавливаться обновления на другие компьютеры")
	RegWrite REG_DWORD, HKEY_CURRENT_USER\Software\VIMPELCOM\InternetOffice\Dealer_On_Line\System, Master, 0
    }
}

; начальные проверки закончены, можно запускать
runAppAgain:
Run "%ProgramFilesx86%\Internet Explorer\iexplore.exe" https://dealer.beeline.ru/dealer/DOL2/DOL.application

SplashTextOn 250,50,%ScriptTitle%, DOL2 запущен`, ожидается появление окна (обычно до двух минут)
WinSet AlwaysOnTop, Off, %ScriptTitle%

DOLNavigatorErrors := ["Не удалось соединиться с Ядром системы (localhost:2000). Не удалось определить значение ключа 'LogMask' в таблице конфигурации"]

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

    
    IfWinExist Обзор папок ahk_class #32770 ahk_exe DOLNavigator.exe, Выберите папку для хранения данных приложения DOL:
    {
	SplashTextOff
	Progress A M ZH0, В окне выбора папки укажите:`n%DOL2ReqdBaseDir%`n`nЕсли указать не ту папку`, самостоятельно не исправить. В таком случае делайте заявку (l.mobilmir.ru/newtaskdept).,,%ScriptTitle%
	
	Loop
	{
	    Sleep 500
	    RegRead dol2regRootDir, %DOL2SettingsKey%, RootDir
	} Until !ErrorLevel
	
	If (dol2regRootDir!=DOL2ReqdBaseDir) {
	    ShowError("Выбрана папка """ . dol2regRootDir """", "Вы отменили выбор или выбрали не ту папку. Чтобы исправить, надо удалить записи из реестра и переустановить DOL2.")
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
    
    For i,wintext in DOLNavigatorErrors {
	IfWinExist On Line Dealer ahk_class #32770 ahk_exe DOLNavigator.exe, %wintext%
	{
	    WinGetTitle fullTitle
	    WinGetText fullText
	    SplashTextOff
	    FileAppend %A_Now% Обнаружено окно: [%fullTitle%]`n%fullText%`n`n
	    ShowError("Обнаружено окно DOLNavigator с ошибкой """ . wintext . """")
	    ExitApp
	}
    }
    
    IfWinExist DOL Навигатор - (Дилер: ahk_exe DOLNavigator.exe
	break
}

SplashTextOff

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
    Loop 3
    {
	Run http://l.mobilmir.ru/newtaskdept
	MsgBox 0x1030, %title%, %text%.`n%explain%`nНезамедлительно сообщите в службу ИТ и не используйте DOL2 на этом компьютере до исправления.
    } Until A_TickCount > endTime
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
