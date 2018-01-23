#NoEnv

For i, RunPath in [ "\\Srv1S.office0.mobilmir\1S\Дистрибутив\install.ahk"
		  , "\\Srv1S\1S\Дистрибутив\install.ahk"
		  , "" ] {
    If (!RunPath)
	MsgError("Не найден путь к скрипту создания ярлыков. Сервера нет в сети или Ваш пароль на сервере отличается от установленного на компьютере.")
} Until FileExist(RunPath)

Loop
{
    RunWait "%A_AhkPath%" "%RunPath%" /s,,UseErrorLevel
    If (ErrorLevel)
	MsgError("Cкрипт создания ярлыка (""" RunPath """) вернул код ошибки " ErrorLevel " [ошибка Windows: " A_LastError "]")
    Else
	break
}

FileDelete %A_ScriptFullPath%

;Yes/No 0x4
;Icon Question 0x20
;Makes the 2nd button the default 0x100
MsgBox 0x124, Открыть справку?, Открыть справку о доступе в 1С?`n`nЕсли у Вас нет пароля для доступа в 1С`, Вы узнаете`, как его получить.
IfMsgBox Yes
    Run http://help.mobilmir.ru/rules/access-to-1cv8-offce

MsgError(txt := "") {
    If (!txt)
	txt=Можно Повторить (Retry) или Отменить (Cancel).
    ; Icon Exclamation 0x30
    ; Retry/Cancel 0x5
    MsgBox 0x35, Ошибка при создании ярлыков 1С, %txt%
    IfMsgBox Cancel
	ExitApp
}
