#NoEnv
#SingleInstance force

ProxySetupScriptPath=\\Srv0.office0.mobilmir\profiles$\Share\config\_Scripts\SetProxy.ahk

TryRunProxySetup:
RunWait "%A_AhkPath%" "%ProxySetupScriptPath%" 192.168.1.1:3128,,UseErrorLevel

If ErrorLevel=ERROR
{
    MsgBox 18, Скрипт настройки прокси-сервера недоступен, Можно попробовать запустить его ещё раз (Повтор`, Retry)`, Прервать (Abort) попытку запуска сейчас и запустить его при следующем входе в систему`, либо игнорировать (Ignore) ошибку и не запускать его вообще.`n`nЕсли РС находится в офисе`, прокси необходим для доступа в Интернет`, работы календаря в Thunderbird и некоторых некоторых других функций и программ.
    IfMsgBox Retry
	GoTo TryRunProxySetup
    IfMsgBox Abort
	Exit
}

FileDelete %A_ScriptFullPath%
