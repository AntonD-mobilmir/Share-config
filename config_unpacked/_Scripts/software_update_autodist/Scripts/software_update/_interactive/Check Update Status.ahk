#NoEnv
#SingleInstance force

IfExist %1%\*.log
    SUScriptsStatus=%1%
Else {
    EnvGet SUScriptsStatus, SUScriptsStatus
    If Not SUScriptsStatus {
	ScriptRunCommand:=DllCall( "GetCommandLine", "Str" )
	RunWait %comspec% /C c:\Local_Scripts\_get_SoftUpdateScripts_source.cmd & START "" %ScriptRunCommand%,, Min
    }
}

EnvAdd BootDateTime, -A_TickCount/1000, s


checkagain:
textMsgBoxNF=`n`n(через 60 секунд либо при нажатии OK данное сообщение будет скрыто`, и статус будет выводиться рядом с часами)
timeLastModified:=0
timeLastModifiedRunning:=0
nameLastModified=
nameLastModifiedRunning=

Loop %SUScriptsStatus%\*
{
;    MsgBox timeLastModified: %timeLastModified%`nA_LoopFileTimeModified: %A_LoopFileTimeModified%`nBootDateTime: %BootDateTime%
    If (A_LoopFileTimeModified > BootDateTime) {
	If (timeLastModified < A_LoopFileTimeModified) {
	    timeLastModified := A_LoopFileTimeModified
	    nameLastModified := A_LoopFileName
	}
    
	If (A_LoopFileExt = "running" && timeLastModifiedRunning < A_LoopFileTimeModified) {
	    timeLastModifiedRunning := A_LoopFileTimeModified
	    nameLastModifiedRunning := A_LoopFileName
	}
    }
}

If (!timeLastModified) {
    If (A_TickCount > 900000) {
	textStatus = Со времени последней загрузки обновления не запускались. При стандартных настройках`, обновление запускается не позже 15 минут после загрузки`, так что`, либо обновления не настроены`, либо используются индивидуальные настройки.
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
    
    TimeSinceLastMod=
    EnvSub TimeSinceLastMod, timeLastModified, Minutes

    FormatTime ftimeLast, timeLastModified
    If (extLast = "running") {
	textStatus = Обновление выполняется`, название журнала: %nameLastModified%.`nПоследнее изменение журнала было %ftimeLast% (%TimeSinceLastMod% минут назад).
	If (TimeSinceLastMod > 20) {
	    textStatus = %textStatus%`n`nС помента последнего изменения журнала прошло больше 20 минут`, вероятно`, в процессе обновления произошел сбой`, и в этом сеансе оно уже не завершится.`n`nЕсли это сообщение появилось первый раз`, рекомендуем перезагрузить компьютер`, и дать обновлению завершиться. Иначе сообщите`, пожалуйста`, службе ИТ.
	    finished := 1
	} Else {
	    textStatusMsgBoxAdd = `nЧтобы избежать сбоев`, не стоит использовать программу`, название которой совпадает с названием журнала.
	    textStatusTray = `nПожалуйста, не используйте программу`, пока она обновляется.
	}
    } Else {
	textStatus = Обновление завершено %ftimeLast%.`nПоследний журнал: %nameLastModified% (%TimeSinceLastMod% минут назад).
	finished := 1
    }
}

If (finished)
    textMsgBoxNF:=""

If (msgBoxShown) {
	TrayTip Состояние установки обновлений, %textStatus%%textStatusTray%, 3, 2
	Sleep 3000
	TrayTip
} Else {
    ; 1 = OK/Cancel, 0 = OK
    MsgBox % 64 + 1 - finished, Проверка состояния обновлений, %textStatus%%textStatusMsgBoxAdd%%textMsgBoxNF%, 60
    IfMsgBox Retry
	GoTo checkagain
    msgBoxShown=1
    IfMsgBox Cancel
	Exit
}
If(finished)
    Exit

GoTo checkagain

CheckSuffix(ByRef t, suffix) {
    return SubStr(t, StrLen(t) - StrLen(suffix)) = suffix
}
