;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

Try
    MTProfilePath:=FindThunderbirdProfile()
Catch {
    MsgBox 16, Не найден актуальный профиль Thunderbird, Не удалось найти профиль Thunderbird.`nПродолжение невозможно.
    ExitApp
}

MsgBox 36, Заменить настройки адресной книги business_contacts?,Заменить параметры адресной книги business_contacts указанными в профиле по умолчанию?`nЕсли адресной книги нет`, она будет создана.`n`nБудет обработан профиль в папке "%MTProfilePath%", 60
IfMsgBox No
    Exit

CloseThunderbirdAndWaitProfileUnlock()

ToolTip,, Изменение настроек Business_contacts

FileCopy %A_ScriptDir%\default_profile_template\business_contacts.mab, %MTProfilePath%\business_contacts.mab, 1
FileRead prefs_BusinessContacts, %A_ScriptDir%\prefs-parts\prefs_BusinessContacts.js
FileAppend `n%prefs_BusinessContacts%,*%MTProfilePath%\prefs.js
ToolTip

SplashTextOn 200, 50, Настройки выполнены, Запускается Thunderbird`, подождите
EnvGet ProgramFilesx86,ProgramFiles(x86)
IfNotExist %ProgramFilesx86%
    EnvGet ProgramFilesx86,ProgramFiles
Run "%ProgramFilesx86%\Mozilla Thunderbird\thunderbird.exe", %ProgramFilesx86%\Mozilla Thunderbird
WinWait ahk_group Thunderbird,,30
SplashTextOff

ExitApp

#include <IniFilesUnicode>
#include %A_ScriptDir%\FindThunderbirdProfile.ahk
#include %A_ScriptDir%\CloseThunderbirdAndWaitProfileUnlock.ahk
