;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

#include <IniFilesUnicode>
#include %A_ScriptDir%\FindThunderbirdProfile.ahk
#include %A_ScriptDir%\CloseThunderbirdAndWaitProfileUnlock.ahk

Try
    MTProfilePath:=FindThunderbirdProfile()
Catch {
    MsgBox 16, Не найден актуальный профиль Thunderbird, Не удалось найти профиль Thunderbird.`nПродолжение невозможно.
    ExitApp
}


MsgBox 36, Заменить pgprules.xml?,Заменить список исключений Enigmail?`n`nБудет обработан профиль в папке %profilePath%, 60
IfMsgBox No
    Exit

CloseThunderbirdAndWaitProfileUnlock(MTProfilePath)

FileCopy %A_ScriptDir%\default_profile_template\pgprules.xml, %MTProfilePath%\pgprules.xml, 1

skipProfileUpdate:
SplashTextOn 200, 50, Скрипт завершил работу, Запускается Thunderbird`, подождите

EnvGet ProgramFilesx86,ProgramFiles(x86)
IfNotExist %ProgramFilesx86%
    EnvGet ProgramFilesx86,ProgramFiles
Run "%ProgramFilesx86%\Mozilla Thunderbird\thunderbird.exe", %ProgramFilesx86%\Mozilla Thunderbird

WinWait ahk_group Thunderbird,,30
SplashTextOff
