#NoEnv
#SingleInstance force

EnvGet DefaultsSource,DefaultsSource
If Not DefaultsSource
{
    EnvGet tried_get_defaultconfig_source, tried_get_defaultconfig_source
    If (tried_get_defaultconfig_source!="1")
    {
	EnvSet tried_get_defaultconfig_source, 1
	RunWait %comspec% /C "_get_defaultconfig_source.cmd & "%A_AhkPath%" "%A_ScriptFullPath%"",, Min
	Sleep 5000
	;SingleInstance force, so must not get here
    }
}

IfExist %DefaultsSource%
{
    SplitPath DefaultsSource,,DefaultsSourceDir
} Else {
    DefaultsSourceDir=\\Srv0.office0.mobilmir\profiles$\Share\config
    IfNotExist %DefaultsSourceDir%\_Scripts\SetProxy.ahk
	DefaultsSourceDir=W:\Distributives\config
	IfNotExist %DefaultsSourceDir%\_Scripts\SetProxy.ahk
	    Throw Не найден скрипт настройки прокси
}

SetProxyAhk=%DefaultsSourceDir%\_Scripts\SetProxy.ahk

TryRun:
IfExist %SetProxyAhk%
    RunWait "%SetProxyAhk%",,UseErrorLevel
Else
    MsgBox 18, Скрипт настройки прокси-сервера недоступен, Если РС находится в офисе`, прокси необходим для доступа в Интернет`, работы календаря в Thunderbird и некоторых некоторых других функций и программ.`n`nМожно запустить его ещё раз (Повтор`, Retry)`, Прервать (Abort) попытку запуска сейчас и запустить его при следующем входе в систему`, либо пропустить (Skip) настройку.
    IfMsgBox Retry
	GoTo TryRun
    IfMsgBox Abort
	Exit

FileDelete %A_ScriptFullPath%
