#NoEnv

RunPath=\\Srv0\profiles$\Share\config\_Scripts\SetProxy.ahk

TryRun:
RunWait "%RunPath%",,UseErrorLevel

If ErrorLevel=ERROR
{
    MsgBox 18, Скрипт настройки прокси-сервера недоступен, Если РС находится в офисе`, прокси необходим для доступа в Интернет`, работы календаря в Thunderbird и некоторых некоторых других функций и программ.`n`nМожно запустить его ещё раз (Повтор`, Retry)`, Прервать (Abort) попытку запуска сейчас и запустить его при следующем входе в систему`, либо пропустить (Skip) настройку.
    IfMsgBox Retry
	GoTo TryRun
    IfMsgBox Abort
	Exit
}

FileDelete %A_ScriptFullPath%
