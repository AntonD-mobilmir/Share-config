#NoEnv
#SingleInstance force

global scriptName:="Проверка состояния software_update"
timeoutUpdateStart_ms := 900000
timeoutupdateStarted_s := 20*60

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

s_uSettingsScript=%A_AppDataCommon%\mobilmir.ru\_get_SoftUpdateScripts_source.cmd
checkLocalUpdatercmd:=FirstExisting(A_ScriptDir . "\..\_install\CheckLocalUpdater.cmd", сonfigDir . "\_Scripts\software_update_autodist\CheckLocalUpdater.cmd")

; RunWait %comspec% /C "%checkLocalUpdatercmd%",,Hide UseErrorLevel
; FileRead pathLastStatus, *P1 *m65536 %A_Temp%\CheckLocalUpdater.flag
; pathLastStatus := Trim(pathLastStatus, "`r`n`t ")
; If (ErrorLevel || !FileExist(pathLastStatus)) {
;     MsgBox 16, %scriptName%, На этом компьютере обновления не работают (скрипт проверки не вернул путь к файлу журнала).
;     ExitApp
; }
; 
; SplitPath pathLastStatus,, dirSUStatus

If (InStr(FileExist(A_AppDataCommon "\mobilmir.ru\SoftUpdateScripts\status"), "D"))
    s_uStatusDirs := [A_AppDataCommon "\mobilmir.ru\SoftUpdateScripts\status"]
Else
    s_uStatusDirs := []

Loop Read, %A_AppDataCommon%\mobilmir.ru\SoftUpdateScripts_source.txt
{
    If (A_Index==1)
        s_uHost := A_LoopReadLine
    Else If (A_Index==2)
        s_uPath := A_LoopReadLine
    Else
        break
}

s_uStatusDirs.Push((s_uHost ? "\\" s_uHost "\" s_uPath : s_uPath) . "\status\" A_ComputerName)

Loop
{
    textMsgBoxNF=`n`n(через 60 секунд либо при нажатии OK данное сообщение будет скрыто`, и статус будет выводиться рядом с часами)
    timeLastLog:=timeBoot
    nameLastLog=
    updateStarted := 0
    
    For i, s_uStatusDir in s_uStatusDirs {
        TrayTip %scriptName%, Проверка папки журналов обновлений (%s_uStatusDir%),, 1
        Loop Files, %s_uStatusDir%\*.*
        {
            ;LibreOffice 4.3.1.ahk.running
            ;LibreOffice 4.3.1.ahk-msiexec.log
            ;If ( EndsWith(A_LoopFileName, "-msiexec.log")
            If (A_LoopFileTimeModified > timeLastLog) {
                If (A_LoopFileName = ".running" || A_LoopFileName = ".log") {
                    updateStarted := A_LoopFileTimeCreated ; когда обновления запускаются, обновляется время файла ".running"
                    If (A_LoopFileName = ".log")
                        updateCompleted := A_LoopFileTimeModified
                } Else
                    timeLastLog := A_LoopFileTimeModified, nameLastLog := A_LoopFileName, dirSUStatus := s_uStatusDir
            }
        }
    }
    TrayTip
    
    If (updateStarted || nameLastLog) {
        timeDiffLastMod := 
        timeDiffLastMod -= timeLastLog, Seconds
	SplitPath nameLastLog,,, extLast, nameLastModNoExt
	
	timeSinceLastMod=
	EnvSub timeSinceLastMod, timeLastLog, Seconds
	If (updateStarted && timeSinceLastMod > timeoutupdateStarted_s)
	    updateStuck := 1
	
	For i, o in [{lim: 60*99, div: 60*60, unit: " ч."}, {lim: 90, div: 60, unit: " мин."}, {lim: 0, div: 1, unit: " с"}]
	    If (timeSinceLastMod > o.lim) {
		timeSinceLastMod := (timeSinceLastMod + o.div//2) // o.div . o.unit ; чтобы использовать математическое округление при целочисленном делении, надо заранее прибавить половину делителя
		break
	    }
	
	If (updateCompleted) {
            FormatTime ftimeLast, %updateCompleted%
	    textStatus = Обновление завершено в %ftimeLast%
	    If (nameLastLog)
                textStatus = %textStatus%`nПоследний журнал: %nameLastLog% (%timeSinceLastMod% назад).
	    finished := 1
	} Else {
            FormatTime ftimeLast, %timeLastLog%
	    If (updateStuck) {
		textStatus = Последнее изменение журнала "%nameLastModNoExt%" было %ftimeLast% (%timeSinceLastMod% назад)`, но обновление не отмечено`, как завершенное. Возможно`, в процессе обновления произошел сбой`, и в этом сеансе оно уже не завершится.`n`nЕсли это сообщение появилось первый раз`, рекомендуем перезагрузить компьютер`, и дать обновлению завершиться. Иначе сообщите`, пожалуйста`, службе ИТ.
		finished := 1
	    } Else {
		textStatus = Обновление выполняется`, название:`n"%nameLastModNoExt%"`, последнее изменение %ftimeLast% (%timeSinceLastMod% назад).
		textStatusMsgBoxAdd = `nЧтобы избежать сбоев`, не стоит использовать программу`, название которой совпадает с названием журнала.
		textStatusTray = `nПожалуйста, не используйте программу`, пока она обновляется.
	    }
	}
    } Else {
	FileGetTime timeLastLog, %pathLastStatus%
	FormatTime ftLastModified, %timeLastLog%
	FormatTime ftBoot, %timeBoot%
	If (A_TickCount > timeoutUpdateStart_ms) {
	    textStatus = Со времени последней загрузки обновления не запускались. При стандартных настройках`, обновление обычно запускается через 15 минут после загрузки`, так что`, либо обновления не настроены`, либо используются индивидуальные настройки.`n`nПоследний журнал: %pathLastStatus%`nВремя завершения: %ftLastModified%`nВремя загрузки: %ftBoot%
	    finished := 1
	} Else {
	    textStatus = Со времени последней загрузки обновление ещё не запустилось.`nЗапуск обновления может откладываться до 15 минут после загрузки`n`n(проверка будет автоматически повторяться каждые 60 секунд)
	    finished := -4 ; In MsgBox options, Retry/Cancel = 5
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

EndsWith(ByRef t, suffix) {
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
