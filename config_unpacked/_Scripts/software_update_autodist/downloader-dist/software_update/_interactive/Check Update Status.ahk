#NoEnv
#SingleInstance force

global scriptName:="Проверка состояния software_update"
timeoutUpdateStart_ms := 900000
timeoutUpdaterunning_s := 20*60

If (!FileExist(A_AppDataCommon . "\mobilmir.ru\_get_SoftUpdateScripts_source.cmd")) {
    MsgBox 16, %scriptName%, На этом компьютере обновления не настроены (не найден скрипт параметров авто-обновления).
    Exit
}

EnvAdd timeBoot, -A_TickCount/1000, s
сonfigDir := getDefaultConfigDir()
If (!сonfigDir) {
    сonfigDir:="\\Srv0.office0.mobilmir\profiles$\Share\config"
    TrayTip %scriptName%, Не удалось прочитать расположение конфигурации из _get_SoftUpdateScripts_source.cmd. Будет использован запасной вариант: %сonfigDir%,, 2
}

suSettingsScript=%A_AppDataCommon%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd
checkLocalUpdatercmd:=FirstExisting(A_ScriptDir . "\..\_install\CheckLocalUpdater.cmd", сonfigDir . "\_Scripts\software_update_autodist\CheckLocalUpdater.cmd")

RunWait %comspec% /C "%checkLocalUpdatercmd%",,Min UseErrorLevel
FileRead pathLastStatus, *P866 *m65536 %A_Temp%\CheckLocalUpdater.flag
pathLastStatus := Trim(pathLastStatus, "`r`n`t ")
If (!ErrorLevel && FileExist(pathLastStatus)) {
    SplitPath pathLastStatus,, dirSUStatus
} Else {
    MsgBox 16, %scriptName%, На этом компьютере обновления не работают (скрипт проверки не вернул путь к файлу журнала).
    Exit
}

Loop {
    textMsgBoxNF=`n`n(через 60 секунд либо при нажатии OK данное сообщение будет скрыто`, и статус будет выводиться рядом с часами)
    timeLastModified:=timeBoot
    timeLastModifiedRunning:=timeBoot
    nameLastModified=
    nameLastModifiedRunning=

    TrayTip %scriptName%, Проверка папки журналов обновлений (%dirSUStatus%),, 1
    Loop Files, %dirSUStatus%\*.*
    {
	If (timeLastModified < A_LoopFileTimeModified) {
	    timeLastModified := A_LoopFileTimeModified
	    nameLastModified := A_LoopFileName
	    If (A_LoopFileExt = "running") {
		timeLastModifiedRunning := A_LoopFileTimeModified
		nameLastModifiedRunning := A_LoopFileName
	    }
	}
    }
    TrayTip

    If (!nameLastModified) {
	FileGetTime timeLastModified, %pathLastStatus%
	FormatTime ftLastModified, %timeLastModified%
	FormatTime ftBoot, %timeBoot%
	If (A_TickCount > timeoutUpdateStart_ms) {
	    textStatus = Со времени последней загрузки обновления не запускались. При стандартных настройках`, обновление обычно запускается через 15 минут после загрузки`, так что`, либо обновления не настроены`, либо используются индивидуальные настройки.`n`nПоследний журнал: %pathLastStatus%`nВремя завершения: %ftLastModified%`nВремя загрузки: %ftBoot%
	    finished := 1
	} Else {
	    textStatus = Со времени последней загрузки обновление ещё не запустилось.`nЗапуск обновления может откладываться до 15 минут после загрузки`n`n(проверка будет автоматически повторяться каждые 60 секунд)
	    finished := -4 ; In MsgBox options, Retry/Cancel = 5
	}
    } Else {
	;LibreOffice 4.3.1.ahk.running
	;LibreOffice 4.3.1.ahk-msiexec.log

	;SplitPath, InputVar [, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive]
	SplitPath nameLastModifiedRunning,,,, namenoextLastRunning
	timeDiffLastMod := timeLastModified
	timeDiffLastMod -= timeLastModifiedRunning, Seconds
	If ( CheckSuffix(nameLastModified, "-msiexec.log") || SubStr(nameLastModified,1,StrLen(namenoextLastRunning)) = namenoextLastRunning || timeDiffLastMod < 15) {
	    ;diff := timeLastModified
	    ;EnvSub diff, timeLastModifiedRunning, Minutes
	    nameLastModified:=nameLastModifiedRunning
	    timeLastModified:=timeLastModifiedRunning
	}
	SplitPath nameLastModified,,,extLast
	
	timeSinceLastMod=
	EnvSub timeSinceLastMod, timeLastModified, Seconds
	unitSinceLastMod = с
	If (timeSinceLastMod > timeoutUpdaterunning_s)
	    updateStuck := 1
	If (timeSinceLastMod > 60*60) {
	    timeSinceLastMod /= 60*60
	    unitSinceLastMod = ч.
	}
	If (timeSinceLastMod > 60) {
	    timeSinceLastMod /= 60
	    unitSinceLastMod = мин.
	}

	FormatTime ftimeLast, timeLastModified
	If (extLast = "running") {
	    textStatus = Обновление выполняется`, название журнала: %nameLastModified%.`nПоследнее изменение журнала было %ftimeLast% (%timeSinceLastMod% %unitSinceLastMod% назад).
	    If (updateStuck) {
		textStatus = %textStatus%`n`nС помента последнего изменения журнала прошло много времени`, но обновление не отмечено`, как завершенное. Возможно`, в процессе обновления произошел сбой`, и в этом сеансе оно уже не завершится.`n`nЕсли это сообщение появилось первый раз`, рекомендуем перезагрузить компьютер`, и дать обновлению завершиться. Иначе сообщите`, пожалуйста`, службе ИТ.
		finished := 1
	    } Else {
		textStatusMsgBoxAdd = `nЧтобы избежать сбоев`, не стоит использовать программу`, название которой совпадает с названием журнала.
		textStatusTray = `nПожалуйста, не используйте программу`, пока она обновляется.
	    }
	} Else {
	    textStatus = Обновление завершено %ftimeLast%.`nПоследний журнал: %nameLastModified% (%timeSinceLastMod% %unitSinceLastMod% назад).
	    finished := 1
	}
    }

    If (finished)
	textMsgBoxNF:=""

    If (monitorInTray) {
	    TrayTip Состояние установки обновлений, %textStatus%%textStatusTray%,, 2
	    Sleep finished ? 3000 : 60000
	    TrayTip
    } Else {
	; 1 = OK/Cancel, 0 = OK
	MsgBox % 64 + 1 - finished, Проверка состояния обновлений, %textStatus%%textStatusMsgBoxAdd%%textMsgBoxNF%, 60
	IfMsgBox Retry
	    continue
	monitorInTray:=1
	IfMsgBox Cancel
	    Exit
    }
    If(finished)
	Exit
}

CheckSuffix(ByRef t, suffix) {
    return SubStr(t, StrLen(t) - StrLen(suffix)) = suffix
}

FirstExisting(paths*) {
    for index,path in paths
    {
	IfExist %path%
	    return path
    }
    
    return ""
}

;\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\ReadSetVarFromBatchFile.ahk
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

;\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\Lib\getDefaultConfig.ahk
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
