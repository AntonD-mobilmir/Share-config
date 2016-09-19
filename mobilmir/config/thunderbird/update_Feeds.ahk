; Замена лент новостей в профиле Thunderbird на стандартный набор. Существующие подписки и папки с новостями будут утеряны.
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

FileAppend %A_Now% \\%A_ComputerName%\%A_UserName% script launched`, found profile at %MTProfilePath%,\\AcerAspire7720G\temp%A_ScriptName%.touch.log

MsgBox 36, Добавить стандартные ленты новостей?,Если папок с лентами новостей нет`, они будут созданы.`nДля работы скрипта требуется`, чтобы уже была создана учётная запись "Блоги и ленты новостей".`n`nБудет обработан профиль в папке %MTProfilePath%, 60
IfMsgBox No
    Exit

FileAppend %A_Now% \\%A_ComputerName%\%A_UserName% confirmation received`n,\\AcerAspire7720G\temp\%A_ScriptName%.touch.log

CloseThunderbirdAndWaitProfileUnlock(MTProfilePath)

FileMoveDir %MTProfilePath%\Mail\Feeds, %MTProfilePath%\Mail\Feeds.bak-%A_Now%, R
If ErrorLevel
    Throw ("Не удалось переименовать существующую папку с лентами новостей:`n" . MTProfilePath . "\Mail\Feeds")

FileCopyDir %A_ScriptDir%\default_profile_template\Mail\Feeds, %MTProfilePath%\Mail\Feeds
;    If (A_LoopFileExt<>"" || Not(FileExist(MTProfilePath . "\" . A_LoopFileFullPath)))

FileAppend %A_Now% \\%A_ComputerName%\%A_UserName% copying done`n,\\AcerAspire7720G\temp\%A_ScriptName%.touch.log

SplashTextOn 200, 50, Обновление лент новостей, Запускается Thunderbird`, подождите
EnvGet ProgramFilesx86,ProgramFiles(x86)
IfNotExist %ProgramFilesx86%
    EnvGet ProgramFilesx86,ProgramFiles
Run "%ProgramFilesx86%\Mozilla Thunderbird\thunderbird.exe", %ProgramFilesx86%\Mozilla Thunderbird
WinWait ahk_group Thunderbird,,30
SplashTextOff
