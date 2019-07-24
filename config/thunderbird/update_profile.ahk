; Удаляет существующие дополнения, устанавливает стандартные, и добавляет в файл настроек стандартные общие (не зависящие от учётной записи).
;by LogicDaemon <www.logicdaemon.ru>
;This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License <http://creativecommons.org/licenses/by-sa/4.0/deed.ru>.
#NoEnv

FileEncoding UTF-8
#include <IniFilesUnicode>
#include %A_ScriptDir%\FindThunderbirdProfile.ahk
#include %A_ScriptDir%\CloseThunderbirdAndWaitProfileUnlock.ahk

Try
    MTProfilePath:=FindThunderbirdProfile()
Catch {
    MsgBox 16, Не найден актуальный профиль Thunderbird, Не удалось найти профиль Thunderbird.`nПродолжение невозможно.
    ExitApp
}

MsgBox 36, Заменить дополнения и настройки Mozilla Thunderbird?,Заменить дополнения и настройки в профиле Mozilla Thunderbird?`nВсе дополения будут заменены на имеющиеся в профиле по умолчанию`, некоторые настройки будут также заменены.`n`nБудет обработан профиль в папке %MTProfilePath%, 60
IfMsgBox No
    GoTo skipProfileUpdate

CloseThunderbirdAndWaitProfileUnlock(MTProfilePath)

TrayTip,, Замена дополнений и добавление стандартных настроек
backupPath=%MTProfilePath%\backup_%A_Now%
FileCreateDir	%backupPath%

FileMoveDir	%MTProfilePath%\extensions,	%backupPath%\extensions,	R
Run "%A_AhkPath%" "%A_ScriptDir%\unpack_extensions.ahk" "%MTProfilePath%\extensions",,, PIDofUnpackScript
FileCopyDir	%A_ScriptDir%\default_profile_template\extensions,	%MTProfilePath%\extensions

FileRemoveDir	%MTProfilePath%\Cache, 1
FileRemoveDir	%MTProfilePath%\OfflineCache, 1
FileDelete	%MTProfilePath%\extensions.cache
FileDelete	%MTProfilePath%\extensions.log

FileMove 	%MTProfilePath%\calendar-data,	%backupPath%\calendar-data,	R
FileMove	%MTProfilePath%\extensions.ini,	%backupPath%\*.*
FileMove	%MTProfilePath%\extensions.rdf,	%backupPath%\*.*
FileMove	%MTProfilePath%\pgprules.xml,	%backupPath%\*.*
FileMove	%MTProfilePath%\business_contacts.mab, %backupPath%\*.*
FileCopy	%MTProfilePath%\prefs.js,	%backupPath%\prefs.js

FileCopy	%A_ScriptDir%\default_profile_template\permissions.sqlite,	%MTProfilePath%\*.*, 1
FileCopy	%A_ScriptDir%\default_profile_template\pgprules.xml,		%MTProfilePath%\*.*, 1
FileCopy	%A_ScriptDir%\default_profile_template\user.js,			%MTProfilePath%\*.*, 1
FileCopy	%A_ScriptDir%\default_profile_template\extensions.*,		%MTProfilePath%\*.*, 1
FileCopy	%A_ScriptDir%\default_profile_template\*.mab,			%MTProfilePath%\*,*, 1

FileRead	prefs_BusinessContacts,	%A_ScriptDir%\prefs-parts\prefs_BusinessContacts.js
FileRead	prefsCommon,		%A_ScriptDir%\prefs-parts\prefs_commononly.js
FileAppend	`n%prefs_BusinessContacts%`n`n%prefsCommon%`n, %MTProfilePath%\prefs.js

Process WaitClose, %PIDofUnpackScript%
TrayTip

SplashTextOn 200, 50, Профиль Thunderbird обновлён, Запускается Mozilla Thunderbird`, подождите
EnvGet ProgramFilesx86,ProgramFiles(x86)
IfNotExist %ProgramFilesx86%
    EnvGet ProgramFilesx86,ProgramFiles
Run "%ProgramFilesx86%\Mozilla Thunderbird\thunderbird.exe", %ProgramFilesx86%\Mozilla Thunderbird
WinWait ahk_group Thunderbird,,30

skipProfileUpdate:
SplashTextOff
