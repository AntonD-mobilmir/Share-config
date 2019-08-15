;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.

#NoEnv

Try
    MTProfilePath:=FindThunderbirdProfile()
Catch {
    MsgBox 16, Не найден актуальный профиль Thunderbird, Не удалось найти профиль Thunderbird.`nПродолжение невозможно.
    ExitApp
}

MsgBox 36, Заменить путь для синхронизации адресной книги?,Указать для загрузки адресной книги путь к серверу в офисе?`n`nБудет обработан профиль в папке "%MTProfilePath%", 60
IfMsgBox Yes
{
    CloseThunderbirdAndWaitProfileUnlock()

    ToolTip,, Изменение настроек addressbookssync
    FileAppend,
    (
    user_pref("extensions.addressbookssync.localpath", "\\\\Srv1S-B.office0.mobilmir\\Users\\Public\\Shares\\profiles$\\Share\\adrbooks");
    
    ),*%MTProfilePath%\prefs.js
    ToolTip

    SplashTextOn 200, 50, Настройки выполнены, Запускается Thunderbird`, подождите
    EnvGet ProgramFilesx86,ProgramFiles(x86)
    IfNotExist %ProgramFilesx86%
        EnvGet ProgramFilesx86,ProgramFiles
    Run "%ProgramFilesx86%\Mozilla Thunderbird\thunderbird.exe", %ProgramFilesx86%\Mozilla Thunderbird
    WinWait ahk_group Thunderbird,,30
    SplashTextOff
}

ExitApp

#include <IniFilesUnicode>
#include %A_ScriptDir%\FindThunderbirdProfile.ahk
#include %A_ScriptDir%\CloseThunderbirdAndWaitProfileUnlock.ahk
