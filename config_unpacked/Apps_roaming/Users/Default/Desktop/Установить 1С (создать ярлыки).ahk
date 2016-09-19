#NoEnv

RunPath="\\Srv1S.office0.mobilmir\1S\Дистрибутив\install.ahk"
IfNotExist %RunPath%
    RunPath="\\Srv1S\1S\Дистрибутив\install.ahk"

TryRun:
RunWait "%A_AhkPath%" "%RunPath%",,UseErrorLevel

If ErrorLevel=ERROR
{
    MsgBox 18, Скрипт установки 1С недоступен, Отсутствует подключение к серверу`, нет прав для доступа к скрипту`, или скрипт расположен в другом месте. Можно попробовать запустить его ещё раз (Повтор`, Retry)`, Прервать (Abort) попытку запуска сейчас и запустить его при следующем входе в систему`, либо игнорировать (Ignore) ошибку и не запускать его вообще.
    IfMsgBox Retry
	GoTo TryRun
    IfMsgBox Abort
	Exit
}

FileDelete %A_ScriptFullPath%
