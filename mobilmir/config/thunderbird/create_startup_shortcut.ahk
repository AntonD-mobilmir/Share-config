;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

MsgBox 36, Автозапуск Thunderbird, Создать ярлык для Thunderbird в автозагрузке? В этом случае Thunderbird будет автоматически запускаться при каждом входе в систему., 60
IfMsgBox Yes
{
    EnvGet ProgramFilesx86,ProgramFiles(x86)
    IfNotExist %ProgramFilesx86%
	EnvGet ProgramFilesx86,ProgramFiles
    FileCreateShortcut %ProgramFilesx86%\Mozilla Thunderbird\thunderbird.exe, %A_Startup%\Mozilla Thunderbird.lnk, %ProgramFilesx86%\Mozilla Thunderbird,, Почта,,,, 7
}
